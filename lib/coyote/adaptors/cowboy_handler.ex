defmodule Coyote.Adaptors.Cowboy.Handler do
  alias :cowboy_req, as: Request

  require Logger

  # The gen_server to route the request to is provided here
  def init(transport, req, [mod]) do
    {:ok, req, [mod]}
  end

  def handle(req, [mod]) do
    start = current_time()
    method = request_method(req)

    GenServer.call(mod, {method, req})

    stop = current_time()

    Logger.log :info, fn ->
      diff = time_diff(start, stop)

      ["Sent", ?\s, Integer.to_string(200),
        " in ", formatted_diff(diff)]
    end

    {:ok, req, []}
  end

  defp start_request_worker(mod, req),
    do: Coyote.Request.Supervisor.start_child(mod, req)

  defp request_method(req),
    do: Request.method(req) |> method_to_atom

  defp method_to_atom({method, _req}) when method in ["GET", "POST", "PUT", "PATCH", "DELETE", "OPTION"],
    do: String.downcase(method) |> String.to_atom

  defp current_time,
    do: :os.timestamp()
  defp time_diff(start, stop),
    do: :timer.now_diff(stop, start)

  defp formatted_diff(diff) when diff > 1000,
    do: [diff |> div(1000) |> Integer.to_string, "ms"]
  defp formatted_diff(diff),
    do: [diff |> Integer.to_string, "µs"]

  def terminate(reason, _request, []) do
    :ok
  end
end
