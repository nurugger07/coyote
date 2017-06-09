defmodule Coyote.RequestHandler do
  use GenServer

  require Logger

  @route_bridge Application.get_env(:coyote, :route_bridge, Coyote.RouteBridge)

  def start_link({{from, ref}, request}),
    do: GenServer.start_link(__MODULE__, {{from, ref}, request})

  def init({{from, _ref}, request}) do
    send(self(), :handle_request)
    {:ok, {from, request}}
  end

  def handle_info(:handle_request, {from, {req, args, topology}}) do
    response = case @route_bridge.find_route(req, topology) do
                 {:ok, %Coyote.Topology.Route{pid: pid, route: {method, path}}} ->
                   case GenServer.call(pid, {method, path, args}) do
                     {:error, message} ->
                       Logger.error(message)
                       {:error, "Routing error"}
                     {:ok, _response} = response ->
                       response
                     response ->
                       {:ok, response}
                   end
                 {:error, "No matching routes"} = error ->
                   error
                 nil ->
                   {:error, "No matching route"}
               end

    send(from, response)

    {:stop, :normal, {}}
  end

  def handle_info(:handle_request, {:cast, {req, args, topology}}) do
    case @route_bridge.find_route(req, topology) do
      {:ok, %Coyote.Topology.Route{pid: pid, route: {method, path}}} ->
        GenServer.cast(pid, {method, path, args})
      _ ->
        Logger.error("No matching route for request #{inspect req}")
    end
    {:stop, :normal, {}}
  end

end
