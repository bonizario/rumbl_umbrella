# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Rumbl.Repo.insert!(%Rumbl.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

alias Rumbl.Accounts
alias Rumbl.Multimedia

for category <- ~w(Action Drama Romance Comedy Sci-fi) do
  Multimedia.create_category!(category)
end

{:ok, user} =
  Accounts.register_user(%{
    name: "Gabriel Bonizário",
    username: "bonizario",
    password: "Bonizario1"
  })

{:ok, video} =
  Multimedia.create_video(user, %{
    category_id: 1,
    title: "Elixir: The Documentary",
    url: "https://www.youtube.com/watch?v=lxYFOM3UJzo",
    description:
      "Get ready to explore the origins of the #Elixir​ programming language, the manner in which it handles concurrency and the speed with which it has grown since its creation back in 2011."
  })

Multimedia.annotate_video(user, video.id, %{
  at: 10000,
  body: "For me, this represents Brazil more than Neymar"
})

Accounts.register_user(%{
  name: "Boni",
  username: "boni",
  password: "Bonizario1"
})
