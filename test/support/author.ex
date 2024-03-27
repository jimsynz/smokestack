defmodule Support.Author do
  @moduledoc false

  use Ash.Resource,
    data_layer: Ash.DataLayer.Ets,
    validate_domain_inclusion?: false,
    domain: nil

  ets do
    private? true
  end

  attributes do
    uuid_primary_key :id

    attribute :name, :string, public?: true
    attribute :email, :ci_string, public?: true

    timestamps()
  end

  relationships do
    has_many :posts, Support.Post
  end

  actions do
    defaults [:create, :read, :update, :destroy]
    default_accept :*
  end

  aggregates do
    count :count_of_posts, :posts
  end
end
