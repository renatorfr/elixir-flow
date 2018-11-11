defmodule Simulator do
  def generate_events do
    Stream.repeatedly(fn -> values() end)
  end

  def values do
    {get_type(), get_speed()}
  end

  defp get_type do
    Enum.random([:car, :truck, :motorcycle])
  end

  defp get_speed do
    Enum.random(70..120) * Enum.random(0..1)
  end
end

#window = Flow.Window.count(100)

#window = Flow.Window.global()
#         |> Flow.Window.trigger_every(100)

window = Flow.Window.periodic(3, :second)

Flow.from_enumerable(Simulator.generate_events())
|> Flow.filter(&elem(&1, 1) > 0)
|> Flow.partition(window: window, key: &elem(&1, 0), stages: 1)
|> Flow.reduce(
     fn -> %{} end,
     fn {type, speed}, result_map ->
       Map.update(result_map, "Count: #{type}", 1, &(&1 + 1))
       |> Map.update("Total speed: #{type}", speed, &(&1 + speed))
       |> Map.update(
            "Avg: #{type}",
            0,
            fn _value -> Float.round(Map.get(result_map, "Total speed: #{type}") / Map.get(result_map, "Count: #{type}")) end
          )
     end
   )
|> Flow.on_trigger(
     fn state ->
       IO.inspect(state, label: "Trigger")

       {[state], state}
     end
   )
|> Flow.run()
