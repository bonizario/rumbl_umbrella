defmodule Rumbl.Multimedia.Category do
  use Ecto.Schema

  import Ecto.Changeset
  import Ecto.Query

  alias Ecto.Changeset
  alias Ecto.Query

  @type t :: %__MODULE__{}

  schema "categories" do
    field :name, :string

    timestamps()
  end

  @spec changeset(__MODULE__.t(), map()) :: Changeset.t()
  def changeset(category, params) do
    category
    |> cast(params, [:name])
    |> validate_required([:name])
  end

  @spec alphabetical(__MODULE__) :: Query.t()
  def alphabetical(query) do
    from(c in query, order_by: c.name)
  end
end
