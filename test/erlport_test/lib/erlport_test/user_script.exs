defmodule ErlportTest.UserScript do
  defmacro hello(do: content={name,metadata, stuff}) do
    IO.puts "name: #{name}, metadata: #{inspect metadata}, stuff: #{stuff}"
    quote do
      IO.puts "send the client the id to highlight: #{inspect unquote(metadata[:line])}"
      unquote(content)
    end
  end
end

defmodule ErlportTest.TestUserScript do
  require ErlportTest.UserScript
  def run do
    ErlportTest.UserScript.hello do: 1 + 2
  end
end
