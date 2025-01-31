defmodule StaysSearch.CsvProccesor do
  alias NimbleCSV.RFC4180, as: CSV

  @spec run(String.t()) :: {:ok, list()} | {:error, String.t()}
  def run(path) do
    if File.exists?(path) do
      File.read!(path)
      |> CSV.parse_string(skip_headers: false)
      |> build_map_from_headers()
      |> get_necessary_data()
      |> then(&{:ok, &1})
    else
      {:error, "Archivo CSV no encontrado: #{path}"}
    end
  end

  defp build_map_from_headers([header | rows]) do
    # The first row is the header, the rest are the data rows
    rows
    |> Enum.map(&row_to_map(header, &1))
  end

  defp row_to_map(headers, row) do
    # Combine header keys with row values
    Enum.zip(headers, row)
    # Convert the result into a map
    |> Enum.into(%{})
  end

  defp get_necessary_data(data) do
    Enum.map(
      data,
      fn row ->
        Map.take(row, [
          "title",
          "price_per_night",
          "amenities",
          "rating_overall",
          "rating_cleanliness",
          "rating_accuracy",
          "rating_check_in",
          "rating_communication",
          "rating_location",
          "rating_value",
          "city"
        ])
        |> Map.put("amenities", Jason.decode!(row["amenities"]))
      end
    )
  end
end
