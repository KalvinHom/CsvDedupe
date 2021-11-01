defmodule CSVDedupe.Deduper.EmailDeduper do
  alias CSVDedupe.Utils.MergeData

  # if there's no email, we add it to the :noemail list
  def dedupe(
        parsed_data,
        %{email: email} = row,
        _columns
      )
      when email == "" do
    add_email_to_list(parsed_data, row)
  end

  def dedupe(
        %{unique_emails: unique_emails, cur_id: cur_id} = parsed_data,
        %{email: email} = row,
        columns
      ) do
    case Map.get(unique_emails, email) do
      nil ->
        unique_emails = Map.put(unique_emails, email, cur_id)

        parsed_data
        |> Map.put(:unique_emails, unique_emails)
        |> add_email_to_list(row)

      match ->
        handle_duplicate_email(parsed_data, row, match, columns)
    end
  end

  defp handle_duplicate_email(%{parsed_rows: parsed_rows} = parsed_data, row, match, columns) do
    merged_record =
      parsed_rows
      |> Map.get(match)
      |> MergeData.run(row, columns)

    parsed_rows = Map.put(parsed_rows, match, merged_record)
    Map.put(parsed_data, :parsed_rows, parsed_rows)
  end

  defp add_email_to_list(
         %{cur_id: cur_id, parsed_rows: parsed_rows} = parsed_data,
         row
       ) do
    parsed_rows = Map.put(parsed_rows, cur_id, row)

    Map.merge(parsed_data, %{
      parsed_rows: parsed_rows,
      cur_id: cur_id + 1
    })
  end
end
