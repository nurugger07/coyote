defmodule Coyote.Adaptors.Cowboy.Supervisor do
  use Supervisor

  @moduledoc """

  """

  @supervisor Coyote.Cowboy.Supervisor

  alias Coyote.Adaptors.Cowboy
  alias Coyote.Adaptors.Cowboy.Spec

  def start_link(args \\ %Spec{}),
    do: Supervisor.start_link(__MODULE__, args, name: @supervisor)

  def init(specs) do
    opts = [strategy: :one_for_one]

    specs
    |> child_spec()
    |> supervise(opts)
  end

  def child_spec(specs),
    do: [Cowboy.child_spec(specs.scheme, specs.routes, [], specs.opts)]
end
