defmodule Coyote.RequestWorker do
  use GenServer

  def start_link,
    do: GenServer.start_link(__MODULE__, [])
    def start_link(mod, req),
      do: GenServer.start_link(__MODULE__, [mod, req])

    def init([mod, req]) do
      send(self, {:start_controller, mod, req})

      {:ok, []}
    end

    def handle_info({:start_controller, mod, req}, state) do
      {:ok, pid} = mod.start_link

      {:noreply, [mod, req, pid]}
    end

    def process(pid, method, bindings),
      do: GenServer.call(pid, {:process_reply, method})

    def handle_call({:process_reply, method}, _from, [mod, _req, pid] = state) do
      {status, headers, output} = GenServer.call(pid, method)

      {:reply, {status, headers, output}, state}
    end

end
