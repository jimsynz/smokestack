defmodule Smokestack.DslTest do
  use ExUnit.Case, async: true
  alias Spark.Error.DslError

  defmodule Post do
    @moduledoc false
    use Ash.Resource,
      data_layer: Ash.DataLayer.Ets,
      validate_api_inclusion?: false

    ets do
      private? true
    end

    attributes do
      uuid_primary_key :id

      attribute :title, :string
    end
  end

  defmodule Factory do
    @moduledoc false
    use Smokestack

    factory Post do
      attribute :title, &Faker.Company.catch_phrase/0
    end

    factory Post, :lorem do
      attribute :title, &Faker.Lorem.sentence/0
    end
  end

  test "it compiles" do
    assert Factory.spark_is() == Smokestack
  end

  test "files with multiple default factories for the same resource fail" do
    assert_raise DslError, fn ->
      defmodule MultiDefaultFactory do
        @moduledoc false
        use Smokestack

        factory Post do
          attribute :title, &Faker.Company.catch_phrase/0
        end

        factory Post do
          attribute :title, &Faker.Company.catch_phrase/0
        end
      end
    end
  end

  test "files with multiple named factories for the same resource fail" do
    assert_raise DslError, fn ->
      defmodule MultiNamedFactory do
        @moduledoc false
        use Smokestack

        factory Post, :with_title do
          attribute :title, &Faker.Company.catch_phrase/0
        end

        factory Post, :with_title do
          attribute :title, &Faker.Company.catch_phrase/0
        end
      end
    end
  end

  test "factories with duplicate attributes fail" do
    assert_raise DslError, fn ->
      defmodule MultiAttributeFactory do
        @moduledoc false
        use Smokestack

        factory Post do
          attribute :title, &Faker.Company.catch_phrase/0
          attribute :title, &Faker.Company.catch_phrase/0
        end
      end
    end
  end
end
