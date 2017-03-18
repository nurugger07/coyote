defmodule Coyote.ServerTest do
  use ExUnit.Case

  setup do
    Application.put_env(:coyote, :route_bridge, Coyote.RouteHandler.Sandbox)

    {:ok, client} = ClientRoutes.start_link

    {:ok, handler} = Coyote.RouteHandler.Sandbox.start_link

    Process.monitor handler

    on_exit fn() ->
      Application.delete_env(:coyote, :routes_handler)
    end

    {:ok, %{server: Coyote, client: client}}
  end

  test "register routes with route/0", %{server: server, client: client} do
    {mod, binary, file} = get_code()

    send(server, {:register, {mod, binary, file, &mod.__routes__/0, :default, {client, :nonode@nohost}}})

    assert {:ok, "success"} = GenServer.call(server, {:GET, "/"})
    assert :ok = GenServer.cast(server, {:POST, "/stuff"})
    assert {:error, "No matching routes"} = GenServer.call(server, {:do_stuff, "12323435"})
  end

  test "register routes with custom function", %{server: server, client: client} do
    {mod, binary, file} = get_code()

    send(server, {:register, {mod, binary, file, &mod.custom_routes/0, :default, {client, :nonode@nohost}}})

    assert {:ok, "stuff is done"} =  GenServer.call(server, {:do_stuff, "12323435"})
    assert {:error, "No matching routes"} = GenServer.call(server, {:GET, "/"})
  end

  def get_code,
    do: :code.get_object_code(ClientRoutes)
end
