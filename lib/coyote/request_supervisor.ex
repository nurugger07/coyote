defmodule Coyote.RequestSupervisor do
  use ConsumerSupervisor

  @max_demand 50

  def start_link(),
    do: ConsumerSupervisor.start_link(__MODULE__, :ok)

  def init(:ok),
    do: {:ok,
         children(),
         strategy: :one_for_one,
         subscribe_to: [
           {Coyote.Relay, max_demand: @max_demand}
         ]}

  defp children,
    do: [worker(Coyote.RequestHandler, [], restart: :temporary)]

end
