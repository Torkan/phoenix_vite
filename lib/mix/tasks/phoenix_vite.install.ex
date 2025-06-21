defmodule Mix.Tasks.PhoenixVite.Install do
  @shortdoc "A short description of your task"
  @example "mix phoenix_vite.install --example arg"

  @moduledoc """
  #{@shortdoc}

  Longer explanation of your task

  ## Example

  ```sh
  #{@example}
  ```

  ## Options

  * `--example-option` or `-e` - Docs for your option
  """

  if Code.ensure_loaded?(Igniter) do
    use Igniter.Mix.Task
    alias Igniter.Code.Function

    @impl Igniter.Mix.Task
    def info(_argv, _composing_task) do
      %Igniter.Mix.Task.Info{
        group: :phoenix_vite,
        example: @example,
        schema: [
          bun: :boolean
        ],
        defaults: [
          bun: false
        ],
        aliases: [
          b: :bun
        ],
        required: []
      }
    end

    @impl Igniter.Mix.Task
    def igniter(igniter) do
      app_name = Igniter.Project.Application.app_name(igniter)
      {igniter, endpoint} = Igniter.Libs.Phoenix.select_endpoint(igniter)
      web_module = Igniter.Libs.Phoenix.web_module(igniter)

      # Do your work here and return an updated igniter
      igniter
      |> Igniter.create_new_file("assets/vite.config.mjs", """
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
      |> Igniter.Project.Config.configure(
        "dev.exs",
        app_name,
        [endpoint, :static_url],
        host: "localhost",
        port: 5173
      )
      |> Igniter.Project.Config.configure("prod.exs", app_name, [endpoint], [])
      |> Igniter.Project.Config.configure_runtime_env(
        :prod,
        app_name,
        [endpoint, :cache_static_manifest_latest],
        {:code,
         Sourceror.parse_string!("""
         {#{inspect(app_name)}, "priv/static/.vite/manifest.json"}
         |> PhoenixVite.Manifest.parse()
         |> PhoenixVite.Manifest.cache_static_manifest_latest
         """)}
      )
      |> Igniter.update_file("assets/js/app.js", fn source ->
        Rewrite.Source.update(source, :content, fn content ->
          ~s|import "../css/app.css";\n| <> content
        end)
      end)
      |> Igniter.update_file("assets/js/app.js", fn source ->
        Rewrite.Source.update(source, :content, fn content ->
          ~s|import "vite/modulepreload-polyfill";\n| <> content
        end)
      end)
      |> Igniter.mkdir("assets/public")
      |> Igniter.include_glob("priv/static/**/*")
      |> then(fn igniter ->
        Enum.reduce(igniter.rewrite.sources, igniter, fn {path, _}, igniter ->
          case Path.split(path) do
            ["priv", "static", "assets" | _] ->
              igniter

            ["priv", "static" | rest] ->
              Igniter.move_file(igniter, path, Path.join(["assets", "public" | rest]))

            _ ->
              igniter
          end
        end)
      end)
      |> Igniter.update_file(".gitignore", fn source ->
        Rewrite.Source.update(source, :content, fn content ->
          String.replace(
            content,
            """
            /priv/static/assets/

            # Ignore digested assets cache.
            /priv/static/cache_manifest.json
            """,
            """
            /priv/static/*
            """
          )
        end)
      end)
      |> Igniter.update_file(
        Path.join(["lib", Macro.underscore(web_module), "components/layouts/root.html.heex"]),
        fn source ->
          Rewrite.Source.update(source, :content, fn content ->
            String.replace(
              content,
              """
                  <link phx-track-static rel="stylesheet" href={~p"/assets/css/app.css"} />
                  <script defer phx-track-static type="text/javascript" src={~p"/assets/js/app.js"}>
                  </script>
              """,
              """
                  <PhoenixVite.Components.assets
                    names={["js/app.js", "css/app.css"]}
                    manifest={{#{inspect(app_name)}, "priv/static/.vite/manifest.js"}}
                    dev_server={PhoenixVite.Components.has_vite_watcher?(#{endpoint})}
                    to_url={fn p -> static_url(@conn, p) end}
                  />
              """
            )
          end)
        end
      )
      |> Igniter.Project.TaskAliases.modify_existing_alias("assets.setup", fn zipper ->
        alias = Sourceror.parse_string!(~s|["bun.install --if-missing", "bun assets install"]|)
        {:ok, Igniter.Code.Common.replace_code(zipper, alias)}
      end)
      |> Igniter.Project.TaskAliases.modify_existing_alias("assets.build", fn zipper ->
        alias = Sourceror.parse_string!(~s|["bun vite build"]|)
        {:ok, Igniter.Code.Common.replace_code(zipper, alias)}
      end)
      |> Igniter.Project.TaskAliases.modify_existing_alias("assets.deploy", fn zipper ->
        alias = Sourceror.parse_string!(~s|["assets.build"]|)
        {:ok, Igniter.Code.Common.replace_code(zipper, alias)}
      end)
      |> then(fn igniter ->
        Enum.reduce([:esbuild, :tailwind], igniter, fn dependency, igniter ->
          igniter =
            if endpoint do
              Igniter.Project.Config.configure(
                igniter,
                "dev.exs",
                app_name,
                [endpoint, :watchers],
                [],
                updater: fn zipper ->
                  zipper =
                    case Igniter.Code.Keyword.remove_keyword_key(zipper, dependency) do
                      {:ok, zipper} -> zipper
                      _ -> zipper
                    end

                  {:ok, zipper}
                end
              )
            else
              igniter
            end

          igniter
          |> Igniter.update_elixir_file("config/config.exs", fn zipper ->
            predicate = &Function.argument_equals?(&1, 0, dependency)

            zipper
            |> Function.move_to_function_call_in_current_scope(:config, [2, 3], predicate)
            |> case do
              :error -> :error
              {:ok, zipper} -> Sourceror.Zipper.remove(zipper)
            end
          end)
          |> Igniter.Project.Deps.remove_dep(dependency)
        end)
      end)
      |> with_bun(fn igniter ->
        igniter
        |> Igniter.Project.Deps.add_dep(
          {:bun, "~> 1.4",
           runtime: quote(do: Mix.env() == :dev),
           github: "LostKobrakai/elixir_bun",
           branch: "LostKobrakai-patch-1",
           override: true},
          append?: true
        )
        |> Igniter.create_new_file("assets/package.json", """
        {
          "workspaces": [
            "../deps/*"
          ],
          "dependencies": {
            "phoenix": "workspace:*",
            "phoenix_html": "workspace:*",
            "phoenix_live_view": "workspace:*",
            "tailwindcss": "^4.1.0",
            "topbar": "^3.0.0"
          },
          "devDependencies": {
            "@tailwindcss/vite": "^4.1.10",
            "vite": "^6.3.5"
          }
        }
        """)
        |> Igniter.Project.Config.configure("config.exs", :bun, [:version], "1.2.16")
        |> Igniter.Project.Config.configure(
          "config.exs",
          :bun,
          [:assets],
          {:code, Sourceror.parse_string!(~s|[args: [], cd: Path.expand("../assets", __DIR__)]|)}
        )
        |> Igniter.Project.Config.configure(
          "config.exs",
          :bun,
          [:vite],
          {:code,
           Sourceror.parse_string!(~s|[args: ~w(x vite), cd: Path.expand("../assets", __DIR__)]|)}
        )
        |> Igniter.Project.Config.configure(
          "dev.exs",
          app_name,
          [endpoint, :watchers, :vite],
          {:code, Sourceror.parse_string!(~s|{Bun, :install_and_run, [:vite, ~w(dev)]}|)}
        )
      end)
    end

    def with_bun(%Igniter{} = igniter, callback) when is_function(callback, 1) do
      if igniter.args.options[:bun] do
        callback.(igniter)
      else
        igniter
      end
    end
  else
    use Mix.Task

    @impl Mix.Task
    def run(_argv) do
      Mix.shell().error("""
      The task 'phoenix_vite.install' requires igniter. Please install igniter and try again.

      For more information, see: https://hexdocs.pm/igniter/readme.html#installation
      """)

      exit({:shutdown, 1})
    end
  end
end
