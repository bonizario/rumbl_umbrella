defmodule Rumbl.Multimedia.Annotation do
  use Ecto.Schema

  import Ecto.Changeset

  alias Ecto.Changeset

  @type t :: %__MODULE__{}

  @required_fields [:body, :at]
  @fields @required_fields

  schema "annotations" do
    field :at, :integer
    field :body, :string

    belongs_to :user, Rumbl.Accounts.User
    belongs_to :video, Rumbl.Multimedia.Video

    timestamps()
  end

  @spec changeset(__MODULE__.t(), map()) :: Changeset.t()
  def changeset(annotation, params) do
    annotation
    |> cast(params, @fields)
    |> validate_required(@required_fields)
  end
end
