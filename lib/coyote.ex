defmodule Coyote do
  use Application

  alias Coyote.Adaptors.Cowboy.Spec

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    routes = Coyote.Router.collect_routes |> compile_routes

    children = [
      supervisor(Coyote.Adaptors.Cowboy.Supervisor, [%Spec{routes: routes}]),
      supervisor(Coyote.Controller.Supervisor, []),
    ]

    opts = [strategy: :one_for_one, name: Coyote.Supervisor]
    Supervisor.start_link(children, opts)
  end

  defp compile_routes([]), do: []
  defp compile_routes([{method, route, mod}|rest]),
    do: [route({method, route, mod, nil})|compile_routes(rest)]
  defp compile_routes([{method, route, mod, action}|rest]),
    do: [route({method, route, mod, action})|compile_routes(rest)]
  defp compile_routes([invalid_route|_rest]),
    do: raise "Invaild route definition"

  defp route({method, route, mod, action}) when method in [:GET, :POST, :PUT, :PATCH, :DELETE, :OPTION] do
    {route,
      Coyote.Adaptors.Cowboy.Handler,
      [%Coyote.RouteInfo{method: method, module: mod, action: action, route: route}]}
  end

  def build_route(_route_info),
    do: raise "Invaild HTTP method in route"

end
