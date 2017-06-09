defmodule Coyote.Adaptors.Cowboy do
  use GenServer

  @moduledoc """

  """

  alias Coyote.Adaptors.Cowboy.Spec
  alias Coyote.Adaptors.Cowboy.RouteInfo

  @schema Application.get_env(:coyote, :schema, :http)
  @port Application.get_env(:coyote, :port, 4001)
  @acceptors Application.get_env(:coyote, :acceptors, 100)

  def start_link(args),
    do: GenServer.start_link(__MODULE__, args, name: __MODULE__)

  def init(args) do
    send(self(), {:start_cowboy, args})
    {:ok, []}
  end

  def child_spec(scheme \\ @schema, routes, [], opts \\ [port: @port, acceptors: @acceptors]),
    do: Supervisor.Spec.worker(__MODULE__, [%Spec{scheme: scheme, routes: routes, opts: opts}])

  def update_routes(routes),
    do: GenServer.cast(__MODULE__, {:update_routes, routes})

  def handle_info({:start_cowboy, specs}, _state) do
    dispatch = :cowboy_router.compile([
      {:_, [{"/static/[...]", :cowboy_static, {:priv_dir, :coyote, "assets"}} | specs.routes]}
    ])

    :cowboy.start_http(specs.scheme, specs.opts[:acceptors], [port: specs.opts[:port]], [{:env, [{:dispatch, dispatch}]}])

    {:noreply, specs}
  end

  def handle_info({:update_routes, routes}, specs) do
    specs = %{specs | routes: routes ++ specs.routes}

    dispatch = :cowboy_router.compile([
      {:_, [{"/static/[...]", :cowboy_static, {:priv_dir, :coyote, "assets"}} | specs.routes]}
    ])

    :cowboy.set_env(specs.scheme, :dispatch, dispatch)

    {:noreply, specs}
  end

  def handle_info({:compile_routes, routes}, specs) do
    send(self(), {:update_routes, compile_routes(routes)})
    {:noreply, specs}
  end

  defp compile_routes([]), do: []

  defp compile_routes([{method, route, mod}|rest]),
    do: [route({method, route, mod, nil})|compile_routes(rest)]

  defp compile_routes([{method, route, mod, action}|rest]),
    do: [route({method, route, mod, action})|compile_routes(rest)]

  defp compile_routes([_invalid_route|_rest]),
    do: raise "Invaild route definition"

  defp route({method, route, mod, action}) when method in [:GET, :POST, :PUT, :PATCH, :DELETE, :OPTION] do
    {route,
     Coyote.Adaptors.Cowboy.Handler,
     [%RouteInfo{method: method, module: mod, action: action, route: route}]}
  end
end
