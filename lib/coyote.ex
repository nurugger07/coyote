defmodule Coyote do
  use Application

  @moduledoc """

  """

  def start(:normal, []),
    do: start_link

  def start_link,
    do: Coyote.Supervisor.start_link

  # PUBLIC API

  def call(request),
    do: GenServer.call(Coyote, request)

  def cast(request),
    do: GenServer.cast(Coyote, request)

end
