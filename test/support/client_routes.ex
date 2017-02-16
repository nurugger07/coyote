defmodule ClientRoutes do
  def routes do
    [
      {:GET, "/"},
      {:POST, "/stuff"}
    ]
  end

  def custom_routes do
    [
      {:do_stuff, "12323435"}
    ]
  end
end
