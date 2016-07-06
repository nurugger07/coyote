defmodule Coyote.Adaptors.Cowboy.Supervisor do
  use Supervisor

  @supervisor Coyote.Cowboy.Supervisor

  alias Coyote.Adaptors.Cowboy
  alias Coyote.Adaptors.Cowboy.Spec

  def start_link(%Spec{} = args),
    do: Supervisor.start_link(__MODULE__, args, name: @supervisor)

  def init(args) do
    opts = [strategy: :one_for_one]

    args
    |> child_spec
    |> supervise(opts)
  end

  def child_spec(args),
    do: [Cowboy.child_spec(args.scheme, args.routes, [], args.opts)]

end
