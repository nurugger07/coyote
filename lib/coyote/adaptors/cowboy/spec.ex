defmodule Coyote.Adaptors.Cowboy.Spec do

  @moduledoc """

  """

  defstruct scheme: :http,
    routes: [],
    opts: [port: 4001, acceptors: 100]

end
