defmodule Themis.DynamicPage do
  use Coyote.Handler

  def handle({:get, "/"}, _params) do
    page = Themis.Page.find_default_page
    html = """
    <!DOCTYPE html>
    <html lang="en">
    <head>
    <link rel="stylesheet" href="/static/css/app.css" />
    </head>
    <body>
    #{page.html}
    </body>
    """

    render(html)
  end

  def handle({:get, endpoint}, _params) do
    page = Themis.Page.find_by_slug(endpoint)
    html = """
    <!DOCTYPE html>
    <html lang="en">
    <head>
    <link rel="stylesheet" href="/static/css/app.css" />
    </head>
    <body>
    #{page.html}
    </body>
    """

    render(html)
  end
end
