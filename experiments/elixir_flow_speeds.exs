defmodule ElixirFlow do
  File.stream!("speeds.csv")
  |> Flow.from_enumerable()
  |> Flow.map(&(String.trim(&1, "\n")))
  |> Flow.map(&(String.to_integer(&1)))
  |> Flow.reduce(fn -> %{} end, fn speed, result_map ->
    Map.update(result_map, "COUNT", 1, &(&1 + 1))
    |> Map.update("TOTAL", speed, &(&1 + speed))
    |> Map.update("AVG", 0, fn _value -> round(Map.get(result_map, "TOTAL") / Map.get(result_map, "COUNT")) end)
  end)
  |> Enum.to_list()
  |> IO.inspect()
end
