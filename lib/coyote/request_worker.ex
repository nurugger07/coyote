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

    def process(pid, :POST, path, %{_method: method} = bindings) when method in ["put", "patch","delete"] do
      method = String.downcase(method) |> String.to_atom
      GenServer.call(pid, {:process_reply, {method, path, bindings}})
    end

    def process(pid, method, path, bindings),
      do: GenServer.call(pid, {:process_reply, {method, path, bindings}})

    def handle_call({:process_reply, method}, _from, [mod, req, pid] = state) do
      {status, headers, output} = GenServer.call(pid, method)

      {:reply, {status, headers, output}, state}
    end

end
