# ElasticPriceEngine

This is a prototype for a highly concurrent dynamic pricing engine. 

An "actor" (generic server) can be started with a particular "strategy" (run-time swappable) that declares a price increment (as demand increases) and price decrements (as demand wanes).

[![](https://mermaid.ink/img/eyJjb2RlIjoiZ3JhcGggVERcbkEoRVBFLkFwcGxpY2F0aW9uKSAtLT58c3RhcnR8IEIoRVBFLlN1cGVydmlzb3IpXG5CIC0tPiBDKFJlZ2lzdHJ5KVxuQiAtLT4gRChEeW5hbWljU3VwZXJ2aXNvcilcbkQgLS0-IEUoRW5naW5lIDEpXG5EIC0tPiBGKEVuZ2luZSAyKVxuRCAtLT4gRyhFbmdpbmUgIykiLCJtZXJtYWlkIjp7InRoZW1lIjoiZGVmYXVsdCJ9LCJ1cGRhdGVFZGl0b3IiOmZhbHNlfQ)](https://mermaid-js.github.io/mermaid-live-editor/#/edit/eyJjb2RlIjoiZ3JhcGggVERcbkEoRVBFLkFwcGxpY2F0aW9uKSAtLT58c3RhcnR8IEIoRVBFLlN1cGVydmlzb3IpXG5CIC0tPiBDKFJlZ2lzdHJ5KVxuQiAtLT4gRChEeW5hbWljU3VwZXJ2aXNvcilcbkQgLS0-IEUoRW5naW5lIDEpXG5EIC0tPiBGKEVuZ2luZSAyKVxuRCAtLT4gRyhFbmdpbmUgIykiLCJtZXJtYWlkIjp7InRoZW1lIjoiZGVmYXVsdCJ9LCJ1cGRhdGVFZGl0b3IiOmZhbHNlfQ)

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `elastic_price_engine` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:elastic_price_engine, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/elastic_price_engine](https://hexdocs.pm/elastic_price_engine).

