defmodule Rumbl.Application do
  use Application

  def start(_type, _args) do
    children = [
      Rumbl.Repo
    ]

    opts = [strategy: :one_for_one, name: Rumbl.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
