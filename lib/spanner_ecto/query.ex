defmodule SpannerEcto.Query do
  defstruct [:statement]
  defimpl DBConnection.Query do
    def parse(query, _opts), do: query
    def describe(query, _opts), do: query
    def encode(_query, params, _opts), do: params
    def decode(_query, result, _opts) do
      {:ok, result_set} = result
      rows = Enum.map(result_set.rows, &normalize_row(&1, result_set.metadata.rowType.fields))
      %{num_rows: length(rows), rows: rows}
    end

    defp normalize_row(row, columns) do
      row |> normalize_row(columns, [])
    end

    defp normalize_row([val | vals], [col | cols], acc) do
      type = col.type.code
      casted_val =
        case {type, val} do
          {"INT64", val} when is_binary(val) -> String.to_integer(val)
          {_type, val} -> val
        end
      normalize_row(vals, cols, acc ++ [casted_val])
    end

    defp normalize_row([], [], acc), do: acc
  end
  defimpl String.Chars do
    alias SpannerEcto.Query
    def to_string(%{statement: sttm}) do
      case sttm do
        sttm when is_binary(sttm) -> IO.iodata_to_binary(sttm)
        %{statement: %Query{} = q} -> String.Chars.to_string(q)
      end
    end
  end
end