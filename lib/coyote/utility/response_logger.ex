defmodule Coyote.Utility.ResponseLogger do

  defmacro timed_task(do: block) do
    quote do
      require Logger
      alias Coyote.Utility.ResponseLogger, as: Utility
      start = Utility.current_time()

      unquote(block)

      stop = Utility.current_time()

      Logger.log :info, fn ->
        diff = Utility.time_diff(start, stop)

        ["Sent", ?\s, Integer.to_string(200),
         " in ", Utility.formatted_diff(diff)]
      end
    end
  end

  def current_time,
    do: :os.timestamp()

  def time_diff(start, stop),
    do: :timer.now_diff(stop, start)

  def formatted_diff(diff) when diff > 1000,
    do: [diff |> div(1000) |> Integer.to_string, "ms"]

  def formatted_diff(diff),
    do: [diff |> Integer.to_string, "µs"]

end
