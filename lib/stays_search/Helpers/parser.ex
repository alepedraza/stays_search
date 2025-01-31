defmodule StaysSearch.Helpers.Parser do
  @doc """
    Parse a string to integer or float

    ## Examples

      iex> StayFinder.Helpers.Parser.number("1.2")
      1.2

      iex> StayFinder.Helpers.Parser.number("3")
      3
  """
  @spec number(String.t()) :: {:ok, number()} | {:error, String.t()}
  def number(str) do
    case Integer.parse(str) do
      {int_value, ""} ->
        {:ok, int_value}

      _ ->
        case Float.parse(str) do
          {float_value, ""} -> {:ok, float_value}
          _ -> {:error, "Invalid number format"}
        end
    end
  end

  @doc """
    Normalize strings by removing accents and converting to lowercase

    ## Examples

      iex> StayFinder.Helpers.Parser.normalize_string("Léon")
      "leon"
  """
  @spec normalize_string(String.t()) :: String.t()
  def normalize_string(str) do
    str
    |> String.normalize(:nfd)
    |> String.replace(~r/[^A-Za-z]/, "")
    |> String.downcase()
  end
end
