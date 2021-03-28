defmodule RumblWeb.VideoView do
  use RumblWeb, :view

  alias Rumbl.Multimedia.Category

  @spec category_select_options(list(Category.t())) :: list({String.t(), non_neg_integer()})
  def category_select_options(categories) do
    for category <- categories, do: {category.name, category.id}
  end
end
