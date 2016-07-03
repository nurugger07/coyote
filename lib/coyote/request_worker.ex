defmodule Coyote.RequestWorker do
  use GenServer

  def start_link,
    do: GenServer.start_link(__MODULE__, [])
  def start_link(mod, req),
    do: GenServer.start_link(__MODULE__, [mod, req])

  def init([mod, req]) do
    {:ok, pid} = mod.start_link(req)

    {:ok, [mod, req, pid]}
  end

  def process(pid, method),
    do: GenServer.call(pid, {:process_reply, method})

  def handle_call({:process_reply, method}, _from, [mod, _req, pid] = state) do
    response = GenServer.call(pid, method)

    {:reply, response, state}
  end
end
