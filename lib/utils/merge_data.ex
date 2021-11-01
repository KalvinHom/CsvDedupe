defmodule CSVDedupe.Utils.MergeData do
  def run(source, duplicate, columns) do
    Enum.reduce(columns, source, fn column, acc ->
      case Map.get(acc, column) do
        v when v == "" or is_nil(v) -> Map.put(acc, column, Map.get(duplicate, column))
        _ -> acc
      end
    end)
  end
end
