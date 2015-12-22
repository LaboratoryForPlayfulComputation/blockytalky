defmodule Blockytalky.LayoutView do
  use Blockytalky.Web, :view
  def btu_id do
    Blockytalky.RuntimeUtils.btu_id
  end
end
