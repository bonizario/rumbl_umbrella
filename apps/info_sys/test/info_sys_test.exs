defmodule InfoSysTest do
  use ExUnit.Case

  alias InfoSys.Result

  defmodule TestBackend do
    def name(), do: "Wolfram"

    def compute("result", _opts), do: [%Result{backend: __MODULE__, text: "result"}]

    def compute("none", _opts), do: []

    def compute("timeout", _opts), do: Process.sleep(:infinity)

    def compute("error", _opts), do: raise("error")
  end

  test "compute/2 returns backend results" do
    assert [%Result{backend: TestBackend, text: "result"}] =
             InfoSys.compute("result", backends: [TestBackend])
  end

  test "compute/2 does not return backend results" do
    assert [] = InfoSys.compute("none", backends: [TestBackend])
  end

  test "compute/2 returns no results with timeout" do
    assert InfoSys.compute("timeout", backends: [TestBackend], timeout: 10) == []
  end

  @tag :capture_log
  test "compute/2 discards backend errors" do
    assert InfoSys.compute("error", backends: [TestBackend]) == []
  end
end
