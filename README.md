# PhoenixVite

```sh
mix phx.new …
mix igniter.install phoenix_vite
mix deps.clean --unlock --unused
mix deps.get
mix assets.setup
```

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `phoenix_vite` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:phoenix_vite, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at <https://hexdocs.pm/phoenix_vite>.
