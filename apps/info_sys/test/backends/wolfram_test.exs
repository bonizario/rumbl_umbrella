defmodule InfoSys.WolframTest do
  use ExUnit.Case, async: true

  test "makes requests, reports results, then terminates" do
    actual = InfoSys.compute("1 + 1", []) |> hd()
    assert actual.text == "2"
  end

  test "reports an empty list with no query results" do
    assert InfoSys.compute("none", [])
  end
end
