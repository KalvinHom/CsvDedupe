defmodule CSVDedupe.Deduper.ParsedData do
  defstruct cur_id: 0, parsed_rows: %{}, unique_emails: %{}, unique_phones: %{}
end
