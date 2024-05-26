defmodule Smokestack.DslTest do
  use ExUnit.Case, async: true
  alias Spark.Error.DslError

  defmodule Post do
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

  test "factories can be used" do
    defmodule UsableFactory do
      @moduledoc false
      use Smokestack

      factory Post do
        attribute :title, &Faker.Company.catch_phrase/0
      end
    end

    defmodule FactoryUser do
      @moduledoc false
      use UsableFactory

      def test do
        insert!(Post)
      end
    end

    assert %Post{title: title} = FactoryUser.test()
    assert title =~ ~r/[a-z]+/i
  end

  test "before build hooks can be applied" do
    defmodule BeforeBuildFactory do
      @moduledoc false
      use Smokestack

      factory Post do
        attribute :title, &Faker.Company.catch_phrase/0
        before_build &capitalise_title/1
      end

      def capitalise_title(record) do
        %{record | title: String.upcase(record.title)}
      end
    end

    title = Faker.Company.catch_phrase()
    upper_title = String.upcase(title)
    assert %Post{title: ^upper_title} = BeforeBuildFactory.insert!(Post, attrs: %{title: title})
  end

  test "after build hooks can be applied" do
    defmodule AfterBuildFactory do
      @moduledoc false
      use Smokestack

      factory Post do
        attribute :title, &Faker.Company.catch_phrase/0
        after_build &add_metadata/1
      end

      def add_metadata(record) do
        Ash.Resource.put_metadata(record, :wat, true)
      end
    end

    assert %Post{__metadata__: %{wat: true}} = AfterBuildFactory.insert!(Post)
  end
end
