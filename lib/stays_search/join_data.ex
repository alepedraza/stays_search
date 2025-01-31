defmodule StaysSearch.JoinData do
  @path_csv "priv/csv/rooms.csv"

  alias StaysSearch.Helpers.Parser, as: Helpers
  alias StaysSearch.CsvProccesor

  @doc """
    To combine the REST API with the CSV, we iterated through each city returned by the API,
    taking advantage of the API filter, and compared each record from the CSV.
    To make it more efficient, we used the Task module to handle multiple relationships simultaneously.
    This also works for us if the number of records in the CSV increases.
    Since we don't have an ID to relate the API records with the CSV, the city name was used,
    where special characters are normalized and removed
  """
  def run(cities) do
    with {:ok, data} <- CsvProccesor.run(@path_csv) do
      Task.async_stream(
        cities,
        fn %{"city_name" => city_name} = city ->
          Enum.reduce(data, [], fn %{"city" => csv_city} = csv_option, acc ->
            if match_city(csv_city, city_name) do
              acc ++ [csv_option]
            else
              acc
            end
          end)
          |> then(&Map.put(city, "accommodation_options", &1))
        end,
        max_concurrency: System.schedulers_online() * 3,
        on_timeout: :kill_task
      )
      |> Enum.map(fn {:ok, city} ->
        city
      end)
      |> then(&{:ok, &1})
    end
  end

  defp match_city(csv_city, city) do
    Helpers.normalize_string(csv_city) == Helpers.normalize_string(city)
  end
end
