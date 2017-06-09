defmodule Coyote.Relay do
  use GenStage

  def start_link(),
    do: GenStage.start_link(__MODULE__, :ok, name: __MODULE__)

  def call({from, request}, timeout \\ 5000),
    do: GenStage.call(__MODULE__, {:call, {from, request}}, timeout)

  def cast(request, _timeout \\ 5000),
    do: GenStage.cast(__MODULE__, {:cast, request})

  def init(:ok),
    do: {:producer, {:queue.new, 0}, dispatcher: GenStage.BroadcastDispatcher}

  def handle_demand(incoming_demand, {queue, demand}),
    do: dispatch_requests(queue, incoming_demand + demand, [])

  def handle_call({_call, {origin, request}}, from, {queue, demand}),
    do: dispatch_requests(:queue.in({from, {origin, request}}, queue), demand, [])

  defp dispatch_requests(queue, demand, requests) do
    with d when d > 0 <- demand, {{:value, {from, request}}, queue} <- :queue.out(queue) do
      GenStage.reply(from, :ok)
      dispatch_requests(queue, demand - 1, [request | requests])
    else
      _ ->
        {:noreply, Enum.reverse(requests), {queue, demand}}
    end
  end

end
