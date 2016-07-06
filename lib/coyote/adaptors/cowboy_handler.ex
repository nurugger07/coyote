defmodule Coyote.Adaptors.Cowboy.Handler do
  alias :cowboy_req, as: Request

  require Logger

  def init(transport, req, [%Coyote.RouteInfo{} = info]),
    do: {:ok, req, [info]}

  def handle(req, [info]) do
    start = current_time()
    method = request_method(req)

    # check method against the defined route method
    # can't handle "not found" here

    {bindings, _req} = Request.bindings(req)
    {query_string, _req} = Request.qs(req)

    {:ok, pid} = start_request_worker(info.module, req)

    {status, headers, output} = Coyote.RequestWorker.process(pid, method, bindings)

    Request.reply(status, headers, output, req)

    stop = current_time()

    Logger.log :info, fn ->
      diff = time_diff(start, stop)

      ["Sent", ?\s, Integer.to_string(200),
        " in ", formatted_diff(diff)]
    end

    {:ok, req, [worker: pid]}
  end

  defp start_request_worker(mod, req),
    do: Coyote.Controller.Supervisor.start_child(mod, req)

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

  def terminate(reason, _request, [worker: pid]) do
    GenServer.stop(pid)
    :ok
  end
end
