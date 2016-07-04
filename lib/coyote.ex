defmodule Coyote do
  use Application

  alias Coyote.Adaptors.Cowboy.Spec

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    routes = Coyote.Router.collect_routes |> build_routes
    specs = Coyote.Router.collect_supervisors

    children = [
      supervisor(Coyote.Adaptors.Cowboy.Supervisor, [%Spec{routes: routes}]),
    ]

    opts = [strategy: :one_for_one, name: Coyote.Supervisor]
    Supervisor.start_link(children ++ specs, opts)
  end

  defp build_routes([]), do: []
  defp build_routes([{route, mod}|rest]) do
    [{route, Coyote.Adaptors.Cowboy.Handler, [mod]}| build_routes(rest)]
  end
end
