defmodule Support.Author do
  @moduledoc false

  use Ash.Resource,
    data_layer: Ash.DataLayer.Ets,
    validate_api_inclusion?: false

  ets do
    private? true
  end

  attributes do
    uuid_primary_key :id

    attribute :name, :string
    attribute :email, :ci_string

    timestamps()
  end

  relationships do
    has_many :posts, Support.Post
  end

  actions do
    defaults [:create, :read, :update, :destroy]
  end
end
