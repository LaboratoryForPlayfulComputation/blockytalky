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
  test "time compiles" do
    defmodule KidsCode do
      use Blockytalky.DSL

        start do
          set("item",0)
          for_time 3 do
            set("item", get("item") + 1)
          after
            IO.puts "item: #{inspect get("item")}"
          end
        end
        def loop_times(time) do
          loop()
          :timer.sleep(1)
          if time > 0, do: loop_times(time-1)
        end
      end
      KidsCode.init(:ok)
      KidsCode.loop_times(10)
    end
  end
defmodule TestKidsCode do
  use Blockytalky.DSL
  start do
    set("item",10)
    for_time 5 do
      set("item", get("item") + 1)
    after
      Logger.debug "#{inspect get("item")}"
    end
  end
end
