defmodule Support.Factory do
  @moduledoc false

  use Smokestack

  factory Support.Author do
    attribute :name, &Faker.Person.name/0
    attribute :email, &Faker.Internet.email/0
  end

  factory Support.Author, :trek do
    attribute :name, choose(["JL", "Doc Holoday", "BLT", "Cal Hudson"])

    attribute :email, fn
      %{name: "JL"} -> "captain@entrepreneur.starfleet"
      %{name: "Doc Holoday"} -> "cheifmed@voyager.starfleet"
      %{name: "BLT"} -> "cheifeng@voyager.starfleet"
      %{name: "Cal Hudson"} -> "cal@maquis.stfu"
    end
  end

  factory Support.Post do
    attribute :title, &Faker.Commerce.product_name/0
    attribute :tags, n_times(3..20, &Faker.Lorem.word/0)
    attribute :body, &Faker.Markdown.markdown/0
    attribute :sub_title, &Faker.Lorem.sentence/0
  end

  factory Support.Post, :trek do
    attribute :title,
              choose([
                "On the safety of conference attendance",
                "Who would win? Q vs Kevin Uxbridge - an analysis",
                "Improvised tools for warp core maintenance",
                "Cardassia Prime: Hot or Not?"
              ])

    attribute :body, &Faker.Markdown.markdown/0
  end
end
