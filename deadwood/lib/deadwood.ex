defmodule Deadwood do
  use Application

  def start(_type, _args) do
    {:ok, self()}
  end
end
