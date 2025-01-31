defmodule StaysSearch.CityApi do
  @api_url "https://search.reservamos.mx/api/v2/places?q="

  @spec get_cities(String.t()) :: {:ok, any()} | {:error, String.t()}
  def get_cities(city) do
    case HTTPoison.get(@api_url <> city) do
      {:ok, %HTTPoison.Response{status_code: 201, body: body}} ->
        body
        |> Jason.decode!()
        |> filter_by_cities()
        |> then(&{:ok, &1})

      {:ok, %HTTPoison.Response{status_code: status_code, body: body}} ->
        {:error, "Error en la API: #{status_code} - #{body}"}

      {:error, reason} ->
        {:error, "Error al llamar a la API: #{reason}"}
    end
  end

  def filter_by_cities(places) do
    Enum.filter(places, fn %{"result_type" => type} ->
      type == "city"
    end)
  end
end
