defmodule Coyote.ServerTest do
  use ExUnit.Case

  defmodule RequestWorker do

    def call(_pid, {:GET, "/"}) do
      {:ok, "success"}
    end

    def call(_pid, {:do_stuff, "12323435"}) do
      {:ok, "stuff is done"}
    end

    def cast(_pid, {:POST, "/stuff"}) do
      :ok
    end
  end

  setup do
    Application.put_env(:coyote, :routes_handler, Coyote.RouteHandler.Sandbox)
    Application.put_env(:coyote, :request_worker, RequestWorker)

    {:ok, handler} = Coyote.RouteHandler.Sandbox.start_link

    Process.monitor handler

    {:ok, pid} = Coyote.Server.start_link

    on_exit fn() ->
      Application.delete_env(:coyote, :routes_handler)
    end

    {:ok, %{server: pid, handler: handler}}
  end

  test "register routes with route/0", %{server: server} do
    {mod, binary, file} = get_code()

    GenServer.cast(server, {:register, {mod, binary, file, {self(), :nonode@nohost}}})

    assert {:ok, "success"} = GenServer.call(server, {:GET, "/"})
    assert :ok = GenServer.cast(server, {:POST, "/stuff"})
    assert {:error, "No matching route"} = GenServer.call(server, {:do_stuff, "12323435"})
  end

  test "register routes with custom function", %{server: server} do
    {mod, binary, file} = get_code()

    GenServer.cast(server, {:register, {mod, binary, file, &mod.custom_routes/0, {self(), :nonode@nohost}}})

    assert {:ok, "stuff is done"} =  GenServer.call(server, {:do_stuff, "12323435"})
    assert {:error, "No matching route"} = GenServer.call(server, {:GET, "/"})
  end

  def get_code,
    do: :code.get_object_code(ClientRoutes)
end
