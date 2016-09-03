defmodule Themis.Root do
  use Coyote.Handler

  def handle({:get, "/pages"}, %{}) do
    html = """
    <!DOCTYPE html>
    <html lang="en">
    <head>
    <link rel="stylesheet" href="/static/css/app.css" />
    </head>
    <body>
    <h1> Welcome!</h1>
    Here are the available posts: <br />
    #{Themis.Page.all}
    </body>
    """

    render(html)
  end

  def handle({:get, "/pages/new"}, %{}) do
    html = """
    <!DOCTYPE html>
    <html lang="en">
    <head>
    <link rel="stylesheet" href="/static/css/app.css" />
    </head>
    <body>
    <h1> Welcome!</h1>
    Here are the available posts: <br />
    #{Themis.Page.all}
    </body>
    """

    render(html)
  end

  def handle({:get, << "/pages", _rest :: binary >>}, %{slug: slug} = params) do
    page = Themis.Page.get(slug)

    html = """
    <!DOCTYPE html>
    <html lang="en">
    <head>
    <link rel="stylesheet" href="/static/css/app.css" />
    </head>
    <body>
    <h1>Page: #{page.name}</h1>
    <form action="/pages#{page.slug}" method="post" enctype="application/x-www-form-urlencoded">
    <input type="hidden" name="_method" value="put" />
    HTML:<br>
    <textarea rows="4" cols="50" name="html">#{page.html}</textarea><br>
    Slug:<br>
    <input type="text" name="slug" value="#{page.slug}"><br><br>
    <input type="submit" value="Submit">
    </form>
    </body>
    """

    render(html)
  end

  def handle({:post, << "/pages", _rest :: binary >>}, params) do
    Themis.Page.update_page(params.slug, params.html)

    html = """
    <!DOCTYPE html>
    <html lang="en">
    <head>
    <link rel="stylesheet" href="/static/css/app.css" />
    </head>
    <body>
    <h1>Saved!</h1><br />
    <a href="/pages">Back to list</a>
    </body>
    """
    render(html)
  end
end
