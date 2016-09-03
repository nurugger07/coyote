defmodule Themis.Router do
  use Coyote.Router

  routes do
    [
      {:GET, "/", Themis.DynamicPage, :index},
      {:POST, "/pages/:slug", Themis.Root},
      {:GET, "/pages/new", Themis.Root},
      {:GET, "/pages/[:slug]", Themis.Root},
      {:GET, "/pages/[:slug]/edit", Themis.Root},
      {:GET, "/pages/preview/[:slug]", Themis.Root}
    ]
  end

end
