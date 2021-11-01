defmodule CSVDedupe.Utils.AddRowToList do
  alias CSVDedupe.Deduper.ParsedData

  def run(
        %ParsedData{cur_id: cur_id, parsed_rows: parsed_rows} = parsed_data,
        row
      ) do
    parsed_rows = Map.put(parsed_rows, cur_id, row)

    Map.merge(parsed_data, %{
      parsed_rows: parsed_rows,
      cur_id: cur_id + 1
    })
  end
end
