defmodule DSLTest do
  use ExUnit.Case

  test "when sensors compiles" do
    defmodule KidsCode do
      use Blockytalky.DSL

      when_sensor "MOCK_3" == 0 do
        IO.puts "hello!"
      end
      when_sensor "MOCK_2" == 1 do
        2 + 2
      end
    end
    assert true
  end

  test "on start compiles" do
    defmodule KidsCode do
      use Blockytalky.DSL

      start do
        IO.puts "Hello"
      end
    end
    KidsCode.init(:ok)
    assert true
  end
end
