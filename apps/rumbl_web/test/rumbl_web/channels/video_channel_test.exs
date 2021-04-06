defmodule RumblWeb.VideoChannelTest do
  use RumblWeb.ChannelCase

  import RumblWeb.TestHelpers

  alias Rumbl.Multimedia
  alias RumblWeb.UserSocket

  setup do
    user = insert_user(name: "John Doe")
    video = insert_video(user, title: "Testing")
    token = Phoenix.Token.sign(@endpoint, "user socket", user.id)
    {:ok, socket} = connect(UserSocket, %{"token" => token})

    on_exit(fn ->
      :timer.sleep(10)

      for pid <- RumblWeb.Presence.fetchers_pids() do
        ref = Process.monitor(pid)
        assert_receive {:DOWN, ^ref, _, _, _}, 1000
      end
    end)

    {:ok, socket: socket, user: user, video: video}
  end

  test "join replies with video annotations", %{socket: socket, video: video, user: user} do
    for body <- ~w(one two) do
      Multimedia.annotate_video(user, video.id, %{body: body, at: 0})
    end

    {:ok, reply, socket} = subscribe_and_join(socket, "videos:#{video.id}", %{})

    assert socket.assigns.video_id == video.id
    assert %{annotations: [%{body: "one"}, %{body: "two"}]} = reply
  end

  test "inserts new annotations", %{socket: socket, video: video} do
    {:ok, _, socket} = subscribe_and_join(socket, "videos:#{video.id}", %{})
    ref = push(socket, "new_annotation", %{body: "Video Body", at: 0})
    assert_reply ref, :ok, %{}
    assert_broadcast "new_annotation", %{}
  end

  test "triggers InfoSys when inserting new annotations", %{socket: socket, video: video} do
    insert_user(username: "wolfram", password: "Password1")
    {:ok, _, socket} = subscribe_and_join(socket, "videos:#{video.id}", %{})
    ref = push(socket, "new_annotation", %{body: "1 + 1", at: 123})
    assert_reply ref, :ok, %{}
    assert_broadcast "new_annotation", %{body: "1 + 1", at: 123}
    assert_broadcast "new_annotation", %{body: "2", at: 123}
  end
end
