defmodule Themis.Page do

  @agent __MODULE__

  def start_link do
    Agent.start_link(fn ->
      [%{id: 1, name: "home", html: "<h1>Hello World</h1>", css: ["app.css"], slug: "/home", root: true},
       %{id: 2, name: "about", html: "<h1>What About Us?</h1>", css: ["app.css"], slug: "/about", root: false},
       %{id: 3, name: "blank", html: "<h1>Blank</h1>", css: [], slug: "/blank", root: false}]
    end, name: @agent)
  end

  def update_page(slug, html) do
    Agent.update(@agent, fn(pages) ->
      Enum.map(pages, fn(page) ->
        merge_page_changes(page, slug, html)
      end)
    end)
  end

  def merge_page_changes(%{slug: page_slug} = page, slug, html) when page_slug == slug,
    do: Map.merge(page, %{slug: slug, html: html})
  def merge_page_changes(page, _slug, _html),
    do: page

  def publish_routes do
    Themis.Page.raw
    |> Enum.map(&build_published_route/1)
    |> Coyote.Adaptors.Cowboy.update_routes
  end

  def publish_route(route) do
    route
    |> build_published_route
    |> Coyote.Adaptors.Cowboy.update_routes
  end

  def find_default_page do
    [page] = Agent.get(@agent, fn(pages) ->
      Enum.filter(pages, fn(page) -> page.root == true end)
    end)
    page
  end

  def build_published_route(page) do
    {page.slug,
     Coyote.Adaptors.Cowboy.Handler,
     [%Coyote.RouteInfo{method: :GET, module: Themis.DynamicPage, route: page.slug}]}
  end

  def raw() do
    Agent.get(@agent, fn(pages) -> pages end)
  end

  def all() do
    pages = Agent.get(@agent, fn(pages) -> pages end)
    |> pages_to_html
    |> Enum.join

    "<ul>#{pages}</ul>"
  end

  def new(page) when is_map(page) do
    case Agent.update(@agent, &([page|&1])) do
      :ok ->
        publish_route(page)
      :error ->
        {:error, page}
    end
  end

  def get(slug) do
    [page] = Agent.get(@agent, fn(pages) ->
      Enum.filter(pages, fn(page) -> page.slug == "/#{slug}" end)
    end)
    page
  end

  def find_by_slug(slug) do
    [page] = Agent.get(@agent, fn(pages) ->
      Enum.filter(pages, fn(page) -> page.slug == slug end)
    end)
    page
  end

  def pages_to_html([]), do: []
  def pages_to_html([page|rest]) do
    ["<li><a href=\"/pages#{page.slug}\">#{page.name}</a></li>"|pages_to_html(rest)]
  end
end
