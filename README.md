# Smokestack

[![Build Status](https://drone.harton.nz/api/badges/james/smokestack/status.svg?ref=refs/heads/main)](https://drone.harton.nz/james/smokestack)
[![Hippocratic License HL3-FULL](https://img.shields.io/static/v1?label=Hippocratic%20License&message=HL3-FULL&labelColor=5e2751&color=bc8c3d)](https://firstdonoharm.dev/version/3/0/full.html)

Smokestack provides a way to define test factories for your [Ash Resources](https://ash-hq.org/docs/module/ash/latest/ash-resource) using a convenient DSL:

```elixir
defmodule Character do
  use Ash.Resource, extension: [Smokestack.Resource]

  attributes do
    uuid_primary_key :id
    attribute :name, :string
    attribute :affiliation, :string
  end

  factory do
    default do
      attribute :name, &Faker.StarWars.character/0
      attribute :affiliation, choose(["Galactic Empire", "Rebel Alliance"])
    end

    variant :trek do
      attribute :name, choose(["J.L. Pipes", "Severn", "Slickback"])
      attribute :affiliation, choose(["Entrepreneur", "Voyager"])
    end
  end
end
```

## Installation

Smokestack is not yet ready to be published to [Hex](https://hex.pm) so in the
mean time if you want to try it you need to add a git-based dependency:

```elixir
def deps do
  [
    {:smokestack, git: "https://code.harton.nz/cinder/cinder", tag: "v0.1.0"}
  ]
end
```

Since the package hasn't been published, there are no docs available on [HexDocs](https://hexdocs.pm/), but you can access the latest version [here](https://docs.harton.nz/james/smokestack).

## License

This software is licensed under the terms of the
[HL3-FULL](https://firstdonoharm.dev), see the `LICENSE.md` file included with
this package for the terms.

This license actively proscribes this software being used by and for some
industries, countries and activities. If your usage of this software doesn't
comply with the terms of this license, then [contact me](mailto:james@harton.nz)
with the details of your use-case to organise the purchase of a license - the
cost of which may include a donation to a suitable charity or NGO.
