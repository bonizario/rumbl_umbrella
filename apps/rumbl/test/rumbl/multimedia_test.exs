defmodule Rumbl.MultimediaTest do
  use Rumbl.DataCase, async: true

  alias Ecto.Changeset
  alias Rumbl.Multimedia
  alias Rumbl.Multimedia.Category
  alias Rumbl.Multimedia.Video

  describe "categories" do
    test "create_category!/1 creates a category with given name" do
      assert %Category{name: name} = Multimedia.create_category!("Sci-fi")
      assert name == "Sci-fi"
    end

    test "list_alphabetical_categories/0" do
      for name <- ~w(Drama Action Comedy) do
        Multimedia.create_category!(name)
      end

      alpha_names =
        for %Category{name: name} <-
              Multimedia.list_alphabetical_categories() do
          name
        end

      assert alpha_names == ~w(Action Comedy Drama)
    end
  end

  describe "videos" do
    @valid_params %{title: "Title", url: "https://example.com", description: "Description"}
    @invalid_params %{title: nil, url: nil, description: nil}

    setup do
      {:ok, user: user_fixture()}
    end

    test "list_videos/0 returns all videos", %{user: owner} do
      %Video{id: id1} = video_fixture(owner)
      assert [%Video{id: ^id1}] = Multimedia.list_videos()
      %Video{id: id2} = video_fixture(owner)
      assert [%Video{id: ^id1}, %Video{id: ^id2}] = Multimedia.list_videos()
    end

    test "get_video!/1 returns the video with given id", %{user: owner} do
      %Video{id: id} = video_fixture(owner)
      assert %Video{id: ^id} = Multimedia.get_video!(id)
    end

    test "create_video/2 creates a video with valid params", %{user: owner} do
      assert {:ok, %Video{} = video} = Multimedia.create_video(owner, @valid_params)
      assert video.title == "Title"
      assert video.url == "https://example.com"
      assert video.description == "Description"
    end

    test "create_video/2 returns error changeset with invalid params", %{user: owner} do
      assert {:error, %Changeset{valid?: false}} = Multimedia.create_video(owner, @invalid_params)
    end

    test "update_video/2 updates the video with valid params", %{user: owner} do
      video = video_fixture(owner)
      assert {:ok, video} = Multimedia.update_video(video, %{title: "New Title"})
      assert %Video{} = video
      assert video.title == "New Title"
    end

    test "update_video/2 returns error changeset with invalid params", %{user: owner} do
      %Video{id: id} = video = video_fixture(owner)
      assert {:error, %Changeset{valid?: false}} = Multimedia.update_video(video, @invalid_params)
      assert %Video{id: ^id} = Multimedia.get_video!(id)
    end

    test "delete_video/1 deletes the video", %{user: owner} do
      video = video_fixture(owner)
      assert {:ok, %Video{}} = Multimedia.delete_video(video)
      assert Multimedia.list_videos() == []
    end

    test "change_video/1 returns a video changeset", %{user: owner} do
      video = video_fixture(owner)
      assert %Changeset{valid?: true} = Multimedia.change_video(video)
    end

    test "list_user_videos/1 returns all videos from the user", %{user: owner} do
      user_fixture() |> video_fixture()
      %Video{id: id1} = video_fixture(owner)
      %Video{id: id2} = video_fixture(owner)
      assert [%Video{id: ^id1}, %Video{id: ^id2}] = Multimedia.list_user_videos(owner)
    end

    test "get_user_video!/2 returns the video with given id from the user", %{user: owner} do
      %Video{id: video_id} = video_fixture(owner)
      assert %Video{user_id: user_id} = Multimedia.get_user_video!(owner, video_id)
      assert user_id == owner.id
    end

    test "user_videos_query/2 returns the videos from the user query", %{user: owner} do
      expected = from(v in Video, where: v.user_id == ^owner.id)
      actual = Multimedia.user_videos_query(Video, owner)
      assert inspect(expected) == inspect(actual)
    end
  end
end
