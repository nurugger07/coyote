defmodule Coyote do
  use Application

  @moduledoc """

  """

  def start(:normal, []),
    do: start_link

  def start_link,
    do: Coyote.Supervisor.start_link

end
