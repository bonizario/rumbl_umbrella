defmodule RumblWeb.Channels.UserSocketTest do
  use RumblWeb.ChannelCase, async: true

  alias RumblWeb.UserSocket

  test "authenticates socket with valid token" do
    token = Phoenix.Token.sign(@endpoint, "user socket", "123")

    assert {:ok, socket} = connect(UserSocket, %{"token" => token})
    assert socket.assigns.user_id == "123"
  end

  test "does not authenticate socket with invalid token" do
    assert :error = connect(UserSocket, %{"token" => "1313"})
    assert :error = connect(UserSocket, %{})
  end
end
