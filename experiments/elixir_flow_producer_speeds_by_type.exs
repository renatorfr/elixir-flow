defmodule Foo do
  def generate_events() do
    Stream.repeatedly(fn -> values() end)
  end

  def values() do
    %{}
    |> Map.put(:type, Enum.random([:car, :truck, :motorcycle]))
    |> Map.put(:speed, get_speed())
  end

  def get_speed() do
    Enum.random(70..120) * Enum.random(0..1)
  end
end

#window = Flow.Window.count(100)

#window = Flow.Window.global()
#         |> Flow.Window.trigger_every(100)

window = Flow.Window.periodic(5, :second)

Flow.from_enumerable(Foo.generate_events())
#|> Flow.each(&IO.inspect(&1))
|> Flow.filter(&Map.get(&1, :speed) > 0)
|> Flow.partition(window: window, key: &Map.get(&1, :type), stages: 1)
|> Flow.reduce(
     fn -> %{} end,
     fn event, result_map ->
       Map.update(result_map, "Count: #{Map.get(event, :type)}", 1, &(&1 + 1))

       |> Map.update(
            "Total speed: #{Map.get(event, :type)}",
            Map.get(event, :speed),
            &(&1 + Map.get(event, :speed))
          )

       |> Map.update(
            "Avg: #{Map.get(event, :type)}",
            0,
            fn _value -> Float.round(Map.get(result_map, "Total speed: #{Map.get(event, :type)}") / Map.get(result_map, "Count: #{Map.get(event, :type)}")) end
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
