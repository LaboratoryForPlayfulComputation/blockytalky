defmodule Blockytalky.PageController do
  use Blockytalky.Web, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
