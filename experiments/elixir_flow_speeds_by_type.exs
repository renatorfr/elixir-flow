defmodule ElixirFlow do
  File.stream!("speeds_by_type.csv")
  |> Flow.from_enumerable()
  |> Flow.map(&(String.trim(&1, "\n")))
  |> Flow.map(&(String.split(&1, ",")))
  |> Flow.partition(key: &List.first(&1))
  |> Flow.reduce(fn -> %{} end, fn line, result_map ->
    Map.update(result_map, "COUNT: " <> List.first(line), 1, &(&1 + 1))
    |> Map.update("TOTAL: " <> List.first(line), String.to_integer(List.last(line)), &(&1 + String.to_integer(List.last(line))))
    |> Map.update("AVG: " <> List.first(line), 0, fn _value -> round(Map.get(result_map, "TOTAL: " <> List.first(line)) / Map.get(result_map, "COUNT: " <> List.first(line))) end)
  end)
  |> Enum.sort()
  |> Enum.to_list()
  |> IO.inspect()
end
