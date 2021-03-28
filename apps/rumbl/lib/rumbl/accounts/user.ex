defmodule Rumbl.Accounts.User do
  use Ecto.Schema

  import Ecto.Changeset

  alias Ecto.Changeset
  alias Rumbl.Validations

  @type t :: %__MODULE__{}

  @required_fields [:name, :username]
  @fields @required_fields

  schema "users" do
    field :name, :string
    field :username, :string
    field :password, :string, virtual: true
    field :password_hash, :string

    timestamps()
  end

  @spec changeset(__MODULE__.t(), map()) :: Changeset.t()
  def changeset(user \\ %__MODULE__{}, params) do
    user
    |> cast(params, @fields)
    |> validate_required(@required_fields)
    |> validate_format(:name, Validations.name_format())
    |> validate_length(:name, max: 70)
    |> validate_format(:username, Validations.username_format())
    |> validate_length(:username, min: 3, max: 20)
    |> unique_constraint(:username)
  end

  @spec registration_changeset(__MODULE__.t(), map()) :: Changeset.t()
  def registration_changeset(user \\ %__MODULE__{}, params) do
    user
    |> changeset(params)
    |> cast(params, [:password])
    |> validate_required([:password])
    |> validate_length(:password, min: 8, max: 100)
    |> validate_format(:password, Validations.password_format())
    |> put_pass_hash()
  end

  defp put_pass_hash(changeset) do
    case changeset do
      %Changeset{valid?: true, changes: %{password: pass}} ->
        put_change(changeset, :password_hash, Pbkdf2.hash_pwd_salt(pass))

      _ ->
        changeset
    end
  end
end
