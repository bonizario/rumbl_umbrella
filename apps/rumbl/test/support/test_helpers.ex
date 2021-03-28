defmodule Rumbl.TestHelpers do
  alias Rumbl.Accounts
  alias Rumbl.Accounts.User
  alias Rumbl.Multimedia
  alias Rumbl.Multimedia.Video

  @spec user_fixture(map()) :: User.t()
  def user_fixture(params \\ %{}) do
    {:ok, user} =
      params
      |> Enum.into(%{
        name: "User",
        username: "user#{System.unique_integer([:positive])}",
        password: params[:password] || "Password123"
      })
      |> Accounts.register_user()

    user
  end

  @spec video_fixture(User.t(), map()) :: Video.t()
  def video_fixture(%Accounts.User{} = user, params \\ %{}) do
    params =
      Enum.into(params, %{
        title: "Title",
        url: "https://example.com",
        description: "Description"
      })

    {:ok, video} = Multimedia.create_video(user, params)

    video
  end
end
