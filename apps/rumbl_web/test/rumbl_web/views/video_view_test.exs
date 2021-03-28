defmodule RumblWeb.VideoViewTest do
  use RumblWeb.ConnCase, async: true

  import Phoenix.View

  alias Rumbl.Multimedia
  alias Rumbl.Multimedia.Category
  alias Rumbl.Multimedia.Video
  alias RumblWeb.VideoView

  test "renders index.html", %{conn: conn} do
    videos = [
      %Video{id: "1", title: "cats"},
      %Video{id: "2", title: "dogs"}
    ]

    content =
      render_to_string(
        VideoView,
        "index.html",
        conn: conn,
        videos: videos
      )

    assert String.contains?(content, "Listing Videos")

    for video <- videos do
      assert String.contains?(content, video.title)
    end
  end

  test "renders new.html", %{conn: conn} do
    changeset = Multimedia.change_video(%Video{})
    categories = [%Category{id: 123, name: "cats"}]

    content =
      render_to_string(
        VideoView,
        "new.html",
        conn: conn,
        changeset: changeset,
        categories: categories
      )

    assert String.contains?(content, "New Video")
  end
end
