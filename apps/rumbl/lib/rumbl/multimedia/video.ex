defmodule Rumbl.Multimedia.Video do
  use Ecto.Schema

  import Ecto.Changeset

  alias Ecto.Changeset
  alias Rumbl.Multimedia.Permalink

  @type t :: %__MODULE__{}

  @primary_key {:id, Permalink, autogenerate: true}

  @required_fields [:url, :title, :description]
  @fields [:category_id | @required_fields]

  schema "videos" do
    field :description, :string
    field :title, :string
    field :url, :string
    field :slug, :string

    belongs_to :user, Rumbl.Accounts.User
    belongs_to :category, Rumbl.Multimedia.Category

    has_many :annotations, Rumbl.Multimedia.Annotation

    timestamps()
  end

  @spec changeset(__MODULE__.t(), map()) :: Changeset.t()
  def changeset(video, params) do
    video
    |> cast(params, @fields)
    |> validate_required(@required_fields)
    |> assoc_constraint(:category)
    |> slugify_title()
  end

  defp slugify_title(changeset) do
    case fetch_change(changeset, :title) do
      {:ok, new_title} -> put_change(changeset, :slug, slugify(new_title))
      :error -> changeset
    end
  end

  defp slugify(string) do
    string
    |> String.downcase()
    |> String.replace(~r/[^\w-]+/u, "-")
  end
end
