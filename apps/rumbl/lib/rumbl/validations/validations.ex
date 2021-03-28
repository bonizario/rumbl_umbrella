defmodule Rumbl.Validations do
  @spec name_format() :: Regex.t()
  def name_format(), do: ~r/^[\p{L}'][ \p{L}'-]*[\p{L}]$/u

  @spec username_format() :: Regex.t()
  def username_format(), do: ~r/^\w+$/

  @spec email_format() :: Regex.t()
  def email_format(), do: ~r/^[A-Za-z0-9\-._%+-+']+@[A-Za-z0-9.-]+\.[A-Za-z]+$/

  @spec password_format() :: Regex.t()
  def password_format(), do: ~r/^(?=.*[a-z].*)(?=.*[A-Z].*)(?=.*[0-9].*)[a-zA-Z0-9]+$/

  @spec phone_format() :: Regex.t()
  def phone_format(), do: ~r/(\(\d{2,}\)|\d{2,})( )?\d{4,}(\-)?\d{4}/
end
