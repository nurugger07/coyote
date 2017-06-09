defmodule Coyote.Adaptors.Cowboy.Handler do

  @moduledoc """

  Used to handle cowboy requests

  """

  @accepted_methods ["GET", "POST", "PUT", "PATCH", "DELETE", "OPTION"]

  alias :cowboy_req, as: Request

  import Coyote.Utility.ResponseLogger

  def init(_transport, req, [%{} = info]),
    do: {:ok, req, [info]}

  def handle(req, _state) do
    timed_task do
      method = request_method(req)

      {path, _req} = request().path(req)

      bindings = atomize_bindings(req)

      headers = [{"content-type", "text/html"}]

      case Coyote.call({method, path, bindings}) do
        {:ok, output} ->
          request().reply(200, headers, output, req)
        {:error, message} ->
          request().reply(500, headers, message, req)
      end
    end

    {:ok, req, []}
  end

  defp atomize_bindings(req) do
    {bindings, _req} = request().bindings(req)
    {query_string, _req} = request().qs_vals(req)
    {:ok, body, _req} = request().body_qs(req)

    body
    |> Enum.into(query_string)
    |> Enum.map(fn({key, val}) ->
      {String.to_atom(key), val}
    end)
    |> Enum.into(bindings)
    |> Enum.into(%{})
  end

  defp request_method(req),
    do: request().method(req) |> method_to_atom

  defp method_to_atom({method, _req}) when method in @accepted_methods,
    do: String.upcase(method) |> String.to_atom

  def terminate(_reason, _request, []),
    do: :ok

  defp request,
    do: Application.get_env(:coyote, :cowboy_request, Request)

end
