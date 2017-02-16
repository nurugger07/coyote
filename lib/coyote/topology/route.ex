defmodule Coyote.Topology.Route do

  @moduledoc """

  Defines the structure for a coyote route.

  """

  defstruct module: nil,
    pid: nil,
    node: nil,
    route: nil,
    description: ""
end
