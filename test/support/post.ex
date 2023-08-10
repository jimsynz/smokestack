defmodule Support.Post do
  @moduledoc false

  use Ash.Resource,
    data_layer: Ash.DataLayer.Ets,
    validate_api_inclusion?: false

  ets do
    private? true
  end

  attributes do
    uuid_primary_key :id

    attribute :title, :string do
      allow_nil? false
    end

    attribute :sub_title, :string

    attribute :tags, {:array, :ci_string} do
      constraints items: [
                    match: ~r/^[a-zA-Z]+$/,
                    casing: :lower
                  ]
    end

    attribute :body, :string do
      allow_nil? false
    end

    timestamps()
  end

  relationships do
    belongs_to :author, Support.Author
  end

  actions do
    defaults [:create, :read, :update, :destroy]
  end
end
