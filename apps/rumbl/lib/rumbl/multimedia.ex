defmodule Rumbl.Multimedia do
  import Ecto.Query, warn: false

  alias Ecto.Changeset
  alias Rumbl.Accounts.User
  alias Rumbl.Multimedia.Annotation
  alias Rumbl.Multimedia.Category
  alias Rumbl.Multimedia.Video
  alias Rumbl.Repo

  @spec create_category!(String.t()) :: Category.t()
  def create_category!(name) do
    Repo.insert!(%Category{name: name}, on_conflict: :nothing)
  end

  @spec list_alphabetical_categories() :: list(Category.t())
  def list_alphabetical_categories() do
    Category
    |> Category.alphabetical()
    |> Repo.all()
  end

  @spec list_videos() :: list(Video.t())
  def list_videos do
    Repo.all(Video)
  end

  @spec get_video!(non_neg_integer()) :: Video.t()
  def get_video!(id), do: Repo.get!(Video, id)

  @spec create_video(User.t(), map()) :: {:ok, Video.t()} | {:error, Changeset.t()}
  def create_video(%User{} = user, params \\ %{}) do
    %Video{}
    |> Video.changeset(params)
    |> Changeset.put_assoc(:user, user)
    |> Repo.insert()
  end

  @spec update_video(Video.t() | struct(), map()) :: {:ok, Video.t()} | {:error, Changeset.t()}
  def update_video(%Video{} = video, params) do
    video
    |> Video.changeset(params)
    |> Repo.update()
  end

  @spec delete_video(Video.t()) :: {:ok, Video.t()} | {:error, Changeset.t()}
  def delete_video(%Video{} = video) do
    Repo.delete(video)
  end

  @spec change_video(Video.t(), map()) :: Changeset.t()
  def change_video(%Video{} = video, params \\ %{}) do
    Video.changeset(video, params)
  end

  @spec list_user_videos(User.t()) :: list(Video.t())
  def list_user_videos(%User{} = user) do
    Video
    |> user_videos_query(user)
    |> Repo.all()
  end

  @spec get_user_video!(User.t(), non_neg_integer()) :: Video.t()
  def get_user_video!(%User{} = user, id) do
    Video
    |> user_videos_query(user)
    |> Repo.get!(id)
  end

  @spec user_videos_query(Video, User.t()) :: Ecto.Query.t()
  def user_videos_query(query, %User{id: user_id}) do
    from(v in query, where: v.user_id == ^user_id)
  end

  @spec annotate_video(User.t(), non_neg_integer(), map()) ::
          {:ok, Annotation.t()} | {:error, Changeset.t()}
  def annotate_video(%User{id: user_id}, video_id, params) do
    %Annotation{user_id: user_id, video_id: video_id}
    |> Annotation.changeset(params)
    |> Repo.insert()
  end

  @spec list_annotations(Video.t(), non_neg_integer()) :: list(Annotation.t())
  def list_annotations(%Video{} = video, last_seen_id \\ 0) do
    from(
      a in Ecto.assoc(video, :annotations),
      where: a.id > ^last_seen_id,
      order_by: [asc: a.at, asc: a.id],
      limit: 500,
      preload: [:user]
    )
    |> Repo.all()
  end
end
