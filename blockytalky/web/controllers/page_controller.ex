defmodule Blockytalky.PageController do
  use Blockytalky.Web, :controller

  plug :action

  def index(conn, _params) do
    render conn, "index.html"
  end
end
