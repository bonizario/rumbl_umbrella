defmodule Rumbl.AccountsTest do
  use Rumbl.DataCase, async: true

  alias Ecto.Changeset
  alias Rumbl.Accounts
  alias Rumbl.Accounts.User

  describe "get_user/1" do
    test "returns the user with given id" do
      user = user_fixture()
      found_user = Accounts.get_user(user.id)
      assert found_user.id == user.id
    end

    test "returns nil with invalid id" do
      assert Accounts.get_user(512) == nil
    end
  end

  describe "get_user!/1" do
    test "returns the user with given id" do
      user = user_fixture()
      found_user = Accounts.get_user!(user.id)
      assert found_user.id == user.id
    end
  end

  describe "get_user_by/1" do
    test "returns the user with given id" do
      user = user_fixture()
      found_user = Accounts.get_user_by(name: "User")
      assert found_user.id == user.id
    end

    test "returns nil with non-matching params" do
      user_fixture()
      assert Accounts.get_user_by(name: "Some User") == nil
      assert Accounts.get_user_by(username: "someuser") == nil
    end
  end

  describe "list_users/0" do
    test "returns all users" do
      %User{id: id1} = user_fixture()
      %User{id: id2} = user_fixture()
      assert [%User{id: ^id1}, %User{id: ^id2}] = Accounts.list_users()
    end
  end

  describe "change_user/2" do
    test "returns a user changeset" do
      user = user_fixture()
      assert %Changeset{valid?: true} = Accounts.change_user(user)
    end
  end

  describe "create_user/1" do
    @valid_params %{name: "User", username: "user"}
    @invalid_params %{}

    test "inserts user with valid params" do
      assert {:ok, %User{id: id} = user} = Accounts.create_user(@valid_params)
      assert user.name == "User"
      assert user.username == "user"
      assert [%User{id: ^id}] = Accounts.list_users()
    end

    test "does not insert user with invalid params" do
      assert {:error, _changeset} = Accounts.create_user(@invalid_params)
      assert Accounts.list_users() == []
    end

    test "requires params to follow valid formats" do
      {:error, changeset} =
        @valid_params
        |> Map.put(:name, "User!?")
        |> Map.put(:username, "@username!?")
        |> Accounts.create_user()

      assert %{
               name: ["has invalid format"],
               username: ["has invalid format"]
             } = errors_on(changeset)

      assert Accounts.list_users() == []
    end

    test "requires params to have valid lengths" do
      {:error, changeset} =
        @valid_params
        |> Map.put(:name, String.duplicate("a", 80))
        |> Map.put(:username, String.duplicate("a", 30))
        |> Accounts.create_user()

      assert %{
               name: ["should be at most 70 character(s)"],
               username: ["should be at most 20 character(s)"]
             } = errors_on(changeset)

      {:error, changeset} =
        @valid_params
        |> Map.put(:username, String.duplicate("a", 2))
        |> Accounts.create_user()

      assert %{username: ["should be at least 3 character(s)"]} = errors_on(changeset)

      assert Accounts.list_users() == []
    end

    test "does not accept non-unique usernames" do
      assert {:ok, %User{id: id}} = Accounts.create_user(@valid_params)
      assert {:error, changeset} = Accounts.create_user(@valid_params)
      assert %{username: ["has already been taken"]} = errors_on(changeset)
      assert [%User{id: ^id}] = Accounts.list_users()
    end
  end

  describe "change_registration/2" do
    test "returns a user changeset" do
      user = user_fixture()

      assert %Changeset{valid?: true, data: %{password: password}} =
               Accounts.change_registration(user)

      refute is_nil(password)
    end
  end

  describe "register_user/1" do
    @valid_params %{name: "User", username: "user", password: "Password123"}
    @invalid_params %{}

    test "inserts user with valid params" do
      assert {:ok, %User{id: id} = user} = Accounts.register_user(@valid_params)
      assert user.name == "User"
      assert user.username == "user"
      assert user.password == "Password123"
      assert [%User{id: ^id}] = Accounts.list_users()
    end

    test "does not insert user with invalid params" do
      assert {:error, _changeset} = Accounts.register_user(@invalid_params)
      assert Accounts.list_users() == []
    end

    test "requires params to follow valid formats" do
      {:error, changeset} =
        @valid_params
        |> Map.put(:password, "12345678")
        |> Accounts.register_user()

      assert %{password: ["has invalid format"]} = errors_on(changeset)

      assert Accounts.list_users() == []
    end

    test "requires params to have valid lengths" do
      {:error, changeset} =
        @valid_params
        |> Map.put(:password, String.duplicate("aA0", 40))
        |> Accounts.register_user()

      assert %{password: ["should be at most 100 character(s)"]} = errors_on(changeset)

      {:error, changeset} =
        @valid_params
        |> Map.put(:password, String.duplicate("aA0", 2))
        |> Accounts.register_user()

      assert %{password: ["should be at least 8 character(s)"]} = errors_on(changeset)

      assert Accounts.list_users() == []
    end

    test "does not accept non-unique usernames" do
      assert {:ok, %User{id: id}} = Accounts.register_user(@valid_params)
      assert {:error, changeset} = Accounts.register_user(@valid_params)
      assert %{username: ["has already been taken"]} = errors_on(changeset)
      assert [%User{id: ^id}] = Accounts.list_users()
    end
  end

  describe "authenticate_by_username_and_pass/2" do
    @password "123ABCabc"

    setup do
      {:ok, user: user_fixture(password: @password)}
    end

    test "returns user with correct password", %{user: user} do
      assert {:ok, auth_user} =
               Accounts.authenticate_by_username_and_pass(user.username, @password)

      assert auth_user.id == user.id
    end

    test "returns unauthorized error with invalid password", %{user: user} do
      assert {:error, :unauthorized} =
               Accounts.authenticate_by_username_and_pass(user.username, "invalid")
    end

    test "returns not_found error with non-existing user" do
      assert {:error, :not_found} =
               Accounts.authenticate_by_username_and_pass("unknownuser", @password)
    end
  end
end
