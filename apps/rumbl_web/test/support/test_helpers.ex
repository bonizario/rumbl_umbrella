defmodule RumblWeb.TestHelpers do
  alias Rumbl.Accounts
  alias Rumbl.Multimedia

  defp default_user() do
    %{
      name: "User",
      username: "user#{System.unique_integer([:positive])}",
      password: "Password1"
    }
  end

  def insert_user(params \\ %{}) do
    {:ok, user} =
      params
      |> Enum.into(default_user())
      |> Accounts.register_user()

    user
  end

  defp default_video() do
    %{
      url: "test@example.com",
      description: "Video Description",
      body: "Video Body"
    }
  end

  def insert_video(user, params \\ %{}) do
    video_fields = Enum.into(params, default_video())
    {:ok, video} = Multimedia.create_video(user, video_fields)
    video
  end

  def login(%{conn: conn, login_as: username}) do
    user = insert_user(username: username)
    {Plug.Conn.assign(conn, :current_user, user), user}
  end

  def login(%{conn: conn}), do: {conn, :logged_out}
end
