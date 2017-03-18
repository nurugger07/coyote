defmodule ClientRoutes do
  use Coyote.Client

  routes do
    [
      {:GET, "/"},
      {:POST, "/stuff"}
    ]
  end

  def custom_routes do
    [
      {:do_stuff, "12323435"}
    ]
  end

  def call({:GET, "/", _args}, _from, state) do
    {:reply, {:ok, "success"}, state}
  end

  def call({:do_stuff, "12323435", _args}, _from, state) do
    {:reply, {:ok, "stuff is done"}, state}
  end

  def cast({:POST, "/stuff", _args}, state) do
    {:noreply, state}
  end
end
