defmodule CSVDedupe.Utils.HandleDuplicateRow do
  alias CSVDedupe.Utils.MergeData
  alias CSVDedupe.Deduper.ParsedData

  def run(%ParsedData{parsed_rows: parsed_rows} = parsed_data, row, match, columns) do
    merged_record =
      parsed_rows
      |> Map.get(match)
      |> MergeData.run(row, columns)

    parsed_rows = Map.put(parsed_rows, match, merged_record)
    Map.put(parsed_data, :parsed_rows, parsed_rows)
  end
end
