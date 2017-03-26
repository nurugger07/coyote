defmodule Coyote.Route.Events do
  use GenServer

  @moduledoc """

  """

  require Logger

  @web_enabled Application.get_env(:coyote, :use_web_adaptor, true)
  @adaptor Coyote.Adaptors.Cowboy
  @route_table Coyote.Topology.RouteTable

  def start_link,
    do: GenServer.start_link(__MODULE__, [], name: __MODULE__)

  def handle_info({message, topology}, _state) do
    if @web_enabled do
      routes = topology
      |> route_table.all
      |> Enum.map(fn(route) ->
        {method, path} = route.route
        {method, path, route.module}
      end)

      send(adaptor, {:compile_routes, routes})
    end
    {:noreply, []}
  end

  def handle_info(unknown, state) do
    Logger.warn("Unknown message to Coyote.Route.Events: #{inspect unknown}")
    {:noreply, state}
  end

  def route_table,
    do: Application.get_env(:coyote, :route_table, @route_table)

  def adaptor,
    do: Application.get_env(:coyote, :adaptor, @adaptor)
end

