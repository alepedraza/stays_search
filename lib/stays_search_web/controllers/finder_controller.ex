defmodule StaysSearchWeb.Finder do
  use StaysSearchWeb, :controller

  require Logger

  alias StaysSearch.CityApi
  alias StaysSearch.JoinData
  alias StaysSearch.Helpers.Parser

  @type params :: %{
          required(:city) => String.t(),
          optional(:ratings) => String.t(),
          optional(:priceMin) => String.t(),
          optional(:priceMax) => String.t(),
          optional(:amenities) => String.t()
        }
  @spec index(Conn.t(), params()) ::
          Plug.Conn.t()
  def index(conn, %{"city" => city} = params) do
    with {:ok, cities} <- CityApi.get_cities(city),
         {:ok, extra_data} <- JoinData.run(cities),
         {:ok, cities_filtered} <- apply_filters(extra_data, params) do
      json(conn, cities_filtered)
    else
      {:error, e} ->
        conn
        |> put_status(:bad_request)
        |> json(%{error: e})
    end
  end

  def index(conn, _params) do
    # Return a 400 Bad Request response if city is missing
    conn
    |> put_status(:bad_request)
    |> json(%{error: "City is required"})
  end

  # Only a filter by general rating was added, but the other rating filters could be added.
  defp apply_filters(cities, %{"ratings" => _ratings} = params),
    do: handle_filter(cities, params, "ratings", "rating_overall", :lt)

  defp apply_filters(cities, %{"priceMin" => _price_min} = params),
    do: handle_filter(cities, params, "priceMin", "price_per_night", :lt)

  defp apply_filters(cities, %{"priceMax" => _price_max} = params),
    do: handle_filter(cities, params, "priceMax", "price_per_night", :gt)

  defp apply_filters(cities, %{"amenities" => _amenities} = params),
    do: handle_filter(cities, params, "amenities", "amenities", :all)

  defp apply_filters(cities, _params), do: {:ok, cities}

  def handle_filter(cities, params, key, list_key, comparisons) do
    with {:ok, parse_key} <- parse_filter_key(params[key], key) do
      Enum.map(cities, fn city ->
        options_filtered =
          Enum.filter(city["accommodation_options"], fn option ->
            case comparisons do
              :lt ->
                String.to_float(option[list_key]) >= parse_key

              :gt ->
                String.to_float(option[list_key]) <= parse_key

              :all ->
                all_elements_present?(parse_key, option[list_key])
            end
          end)

        Map.put(city, "accommodation_options", options_filtered)
      end)
      |> apply_filters(clean_filter(params, key))
    end
  end

  defp clean_filter(params, filter) do
    Map.delete(params, filter)
  end

  def all_elements_present?(filter_list, amenities_list) do
    Enum.all?(filter_list, fn element ->
      Enum.member?(amenities_list, element)
    end)
  end

  defp parse_filter_key(value, key) do
    try do
      case key do
        "amenities" ->
          {:ok, Jason.decode!(value)}

        _numbers ->
          Parser.number(value)
      end
    rescue
      e ->
        Logger.error("Parameter format error: #{inspect(e)}")

        {:error, "Parameter format error: #{key}"}
    end
  end
end
