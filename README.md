# Smokestack

[![Build Status](https://drone.harton.dev/api/badges/james/smokestack/status.svg?ref=refs/heads/main)](https://drone.harton.nz/james/smokestack)
[![Hippocratic License HL3-FULL](https://img.shields.io/static/v1?label=Hippocratic%20License&message=HL3-FULL&labelColor=5e2751&color=bc8c3d)](https://firstdonoharm.dev/version/3/0/full.html)

Smokestack provides a way to define test factories for your [Ash Resources](https://ash-hq.org/docs/module/ash/latest/ash-resource) using a convenient DSL:

```elixir
defmodule MyApp.Factory do
  use Smokestack

  factory Character do
    attribute :name, &Faker.StarWars.character/0
    attribute :affiliation, choose(["Galactic Empire", "Rebel Alliance"])
  end

  factory Character, :trek do
    attribute :name, choose(["J.L. Pipes", "Severn", "Slickback"])
    attribute :affiliation, choose(["Entrepreneur", "Voyager"])
  end
end

defmodule MyApp.CharacterTest do
  use MyApp.DataCase
  use MyApp.Factory

  test "it can build a character" do
    assert character = insert!(Character)
  end
end
```

## Installation

Smokestack is available on [Hex](https://hex.pm/packages/smokestack) you can
add it directly to your `mix.exs`:

```elixir
def deps do
  [
    {:smokestack, "~> 0.9.0"},
  ]
end
```

Documentation for the latest release is available on [HexDocs](http://hexdocs.pm/smokestack).

## Github Mirror

This repository is mirrored [on Github](https://github.com/jimsynz/smokestack)
from it's primary location [on my Forgejo instance](https://harton.dev/james/smokestack).
Feel free to raise issues and open PRs on Github.

## License

This software is licensed under the terms of the
[HL3-FULL](https://firstdonoharm.dev), see the `LICENSE.md` file included with
this package for the terms.

This license actively proscribes this software being used by and for some
industries, countries and activities. If your usage of this software doesn't
comply with the terms of this license, then [contact me](mailto:james@harton.nz)
with the details of your use-case to organise the purchase of a license - the
cost of which may include a donation to a suitable charity or NGO.
