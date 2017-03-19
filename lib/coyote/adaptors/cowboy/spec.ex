defmodule Coyote.Adaptors.Cowboy.Spec do

  @moduledoc """

  """

  defstruct scheme: :http,
    routes: [],
    opts: [port: 4000, acceptors: 100]

end
