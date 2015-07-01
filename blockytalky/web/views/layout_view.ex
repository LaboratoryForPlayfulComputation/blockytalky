defmodule Blockytalky.LayoutView do
  use Blockytalky.Web, :view
  def btu_id do
    Application.get_env(:blockytalky, :id, "Unknown")
  end
end
