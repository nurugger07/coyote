defmodule Coyote.Supervisor do
  use Supervisor

  @moduledoc """

  """

  @supervisor Coyote.Supervisor
  @web_enabled Application.get_env(:coyote, :use_web_adaptor, true)
  @adaptor_supervisor Coyote.Adaptors.Cowboy.Supervisor

  def start_link,
    do: Supervisor.start_link(__MODULE__, [], name: @supervisor)

  def init([]) do
    children = [
      supervisor(Coyote.Topology.Supervisor, []),
      worker(Coyote.Route.Events, []),
      worker(Coyote.Server, [])
    ] |> include_web_adaptor(@web_enabled)

    supervise(children, strategy: :one_for_one)
  end

  defp include_web_adaptor(children, web_enabled) when web_enabled,
    do: [supervisor(adaptor_supervisor(), [])|children]

  defp include_web_adaptor(children, false),
    do: children

  def adaptor_supervisor,
    do: Application.get_env(:coyote, :adaptor_supervisor, @adaptor_supervisor)
end
