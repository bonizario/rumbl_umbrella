defmodule Rumbl.Accounts do
  import Ecto.Query

  alias Ecto.Changeset
  alias Rumbl.Accounts.User
  alias Rumbl.Repo

  @spec get_user(non_neg_integer()) :: User.t() | nil
  def get_user(id) do
    Repo.get(User, id)
  end

  @spec get_user!(non_neg_integer()) :: User.t()
  def get_user!(id) do
    Repo.get!(User, id)
  end

  @spec get_user_by(Keyword.t() | map()) :: User.t() | nil
  def get_user_by(params) do
    Repo.get_by(User, params)
  end

  @spec list_users() :: list(User.t())
  def list_users() do
    Repo.all(User)
  end

  @spec change_user(User.t() | struct(), map()) :: Changeset.t()
  def change_user(%User{} = user, params \\ %{}) do
    User.changeset(user, params)
  end

  @spec create_user(map()) :: {:ok, User.t()} | {:error, Changeset.t()}
  def create_user(params \\ %{}) do
    %User{}
    |> User.changeset(params)
    |> Repo.insert()
  end

  @spec change_registration(User.t(), map()) :: Changeset.t()
  def change_registration(%User{} = user, params \\ %{}) do
    User.registration_changeset(user, params)
  end

  @spec register_user(map()) :: {:ok, User.t()} | {:error, Changeset.t()}
  def register_user(params \\ %{}) do
    %User{}
    |> User.registration_changeset(params)
    |> Repo.insert()
  end

  @spec authenticate_by_username_and_pass(String.t(), String.t()) ::
          {:ok, User.t()} | {:error, :not_found | :unauthorized}
  def authenticate_by_username_and_pass(username, given_pass) do
    user = get_user_by(username: username)

    cond do
      user && Pbkdf2.verify_pass(given_pass, user.password_hash) ->
        {:ok, user}

      user ->
        {:error, :unauthorized}

      true ->
        Pbkdf2.no_user_verify()
        {:error, :not_found}
    end
  end

  @spec list_users_with_ids(list(non_neg_integer())) :: list(User.t())
  def list_users_with_ids(ids) do
    from(u in User, where: u.id in ^ids) |> Repo.all()
  end
end
