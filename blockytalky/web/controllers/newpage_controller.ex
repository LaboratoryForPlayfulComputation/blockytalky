defmodule Blockytalky.HelloController do
  use Blockytalky.Web, :controller
  def world(conn, %{"name" =>name}) do
    render conn, "world.html" , name: name
  end
end
