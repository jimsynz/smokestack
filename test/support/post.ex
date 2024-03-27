defmodule Support.Post do
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

    attribute :title, :string do
      allow_nil? false
      public? true
    end

    attribute :sub_title, :string, public?: true

    attribute :tags, {:array, :ci_string} do
      constraints items: [
                    match: ~r/^[a-zA-Z]+$/,
                    casing: :lower
                  ]

      public? true
    end

    attribute :body, :string do
      allow_nil? false
      public? true
    end

    timestamps()
  end

  relationships do
    belongs_to :author, Support.Author
  end

  actions do
    defaults [:create, :read, :update, :destroy]
    default_accept :*
  end

  calculations do
    calculate :full_title, :string, concat([:title, :sub_title], ": ")
  end
end
