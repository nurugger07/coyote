defmodule Coyote do
  use Application

  def start(:normal, []),
    do: start_link

  def start_link,
    do: Coyote.Supervisor.start_link

end
