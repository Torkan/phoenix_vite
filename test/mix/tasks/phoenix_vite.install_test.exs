defmodule Mix.Tasks.PhoenixVite.InstallTest do
  use ExUnit.Case, async: true
  import Igniter.Test

  test "creates minimal vite.config.mjs" do
    phx_test_project()
    |> Igniter.compose_task("phoenix_vite.install", [])
    |> assert_creates("assets/vite.config.mjs", """
    import { defineConfig } from 'vite'
    import tailwindcss from "@tailwindcss/vite";

    export default defineConfig({
      server: {
        port: 5173,
        strictPort: true,
        cors: { origin: "http://localhost:4000" },
      },
      build: {
        manifest: true,
        rollupOptions: {
          input: ["js/app.js", "css/app.css"],
        },
        outDir: "../priv/static",
        emptyOutDir: true,
      },
      plugins: [tailwindcss()]
    });
    """)
  end

  test "inserts import polyfill to app.js" do
    phx_test_project()
    |> Igniter.compose_task("phoenix_vite.install", [])
    |> assert_has_patch("assets/js/app.js", """
    1 + |import "vite/modulepreload-polyfill";
    """)
  end

  test "moves static files to assets" do
    igniter =
      phx_test_project()
      |> Igniter.compose_task("phoenix_vite.install", [])

    assert {"priv/static/favicon.ico", "assets/public/favicon.ico"} in igniter.moves
  end

  describe "assets/package.json" do
    test "is created if run with bun flag" do
      phx_test_project()
      |> Igniter.compose_task("phoenix_vite.install", ["--bun"])
      |> assert_creates("assets/package.json", """
      {
        "workspaces": [
          "../deps/*"
        ],
        "dependencies": {
          "phoenix": "workspace:*",
          "phoenix_html": "workspace:*",
          "phoenix_live_view": "workspace:*",
          "topbar": "^3.0.0"
        },
        "devDependencies": {
          "tailwindcss": "^4.1.0",
          "daisyui": "^5.0.0",
          "@tailwindcss/vite": "^4.1.0",
          "vite": "^6.3.0"
        }
      }
      """)
    end

    test "is not created if run without bun flag" do
      phx_test_project()
      |> Igniter.compose_task("phoenix_vite.install", ["--no-bun"])
      |> refute_creates("assets/package.json")
    end
  end
end
