defmodule ErlportTest.OscTest do
  def play do
    program = """
    play 60
    sleep 0.25
    play 64
    sleep 0.25
    play 67
    sleep 0.25
    play 72
    """
    m = {:message, '/run-code',[String.to_char_list(program)]}
        |> :osc_lib.encode

    {:ok, socket} = :gen_udp.open(0,[:binary])
    :ok = :gen_udp.send(socket,'localhost',4557,m)
    :gen_udp.close(socket)


  end

end
