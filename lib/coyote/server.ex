defmodule Coyote.Server do
  use GenServer

  alias Coyote.Topology.Route

  def start_link,
    do: GenServer.start_link(__MODULE__, [], name: Server.Worker)

  def init(_args) do
    {:ok, []}
  end

  def handle_cast({:register, {mod, binary, file, node}}, _state),
    do: handle_cast({:register, {mod, binary, file, &mod.routes/0, node}}, [])

  def handle_cast({:register, {mod, binary, file, fun, node}}, _state) do
    {:module, mod} = :code.load_binary(mod, file, binary)

    routes_handler.update_routing_table(fun.(), mod, node)
    {:noreply, []}
  end

  def handle_cast(req, _state) do
    cast_route(req)
    {:noreply, []}
  end

  def handle_call(req, _from, _state) when is_tuple(req),
    do: {:reply, call_route(req), []}

  defp call_route(req) do
    case routes_handler.find_route(req) do
      %Route{pid: pid, route: route} ->
        case request_worker.call(pid, route) do
          {:error, _message} ->
            {:error, "Routing error"}
          response ->
            response
        end
      nil ->
        {:error, "No matching route"}
    end
  end

  defp cast_route(req) do
    case routes_handler.find_route(req) do
      %Route{pid: pid, route: route} ->
        request_worker.cast(pid, route)
      _ ->
        {:error, "No matching route"}
    end
  end

  defp request_worker,
    do: Application.get_env(:coyote, :request_worker, Coyote.RequestWorker)

  defp routes_handler,
    do: Application.get_env(:coyote, :routes_handler, Coyote.RouteHandler)
end
