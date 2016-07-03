defmodule Coyote.Adaptors.Cowboy.Supervisor do
  use Supervisor

  @supervisor Coyote.Cowboy.Supervisor

  alias Coyote.Adaptors.Cowboy
  alias Coyote.Adaptors.Cowboy.Spec

  def start_link(%Spec{} = args),
    do: Supervisor.start_link(__MODULE__, args, name: __MODULE__)

  def init(args) do

    children = [
      Cowboy.child_spec(args.scheme, args.routes, [], args.opts)
    ]

    opts = [strategy: :one_for_one, name: @supervisor]
    supervise(children, opts)
  end

end
