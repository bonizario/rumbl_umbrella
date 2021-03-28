defmodule Rumbl.Multimedia.Permalink do
  use Ecto.Type

  @spec type :: :id
  def type, do: :id

  @spec cast(any()) :: {:ok, integer} | :error
  def cast(binary) when is_binary(binary) do
    case Integer.parse(binary) do
      {int, _} when int > 0 -> {:ok, int}
      _ -> :error
    end
  end

  def cast(integer) when is_integer(integer) do
    {:ok, integer}
  end

  def cast(_), do: :error

  @spec dump(integer()) :: {:ok, integer}
  def dump(integer) when is_integer(integer) do
    {:ok, integer}
  end

  @spec load(integer()) :: {:ok, integer}
  def load(integer) when is_integer(integer) do
    {:ok, integer}
  end
end
