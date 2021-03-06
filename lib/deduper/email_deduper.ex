defmodule CSVDedupe.Deduper.EmailDeduper do
  alias CSVDedupe.Utils.{AddRowToList, HandleDuplicateRow}
  alias CSVDedupe.Deduper.ParsedData

  def dedupe(
        parsed_data,
        %{email: email} = row,
        columns
      )
      when email == "" do
    empty_row? = Enum.all?(columns, fn column -> Map.get(row, column) == "" end)

    case empty_row? do
      true -> parsed_data
      false -> AddRowToList.run(parsed_data, row)
    end
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
        |> AddRowToList.run(row)

      match ->
        HandleDuplicateRow.run(parsed_data, row, match, columns)
    end
  end

  def get_matching_email(%ParsedData{unique_emails: unique_emails}, email) do
    Map.get(unique_emails, email)
  end

  def add_unique_email(%ParsedData{unique_emails: unique_emails} = parsed_data, email, id) do
    case email do
      "" ->
        parsed_data

      email ->
        unique_emails = Map.put(unique_emails, email, id)
        Map.put(parsed_data, :unique_emails, unique_emails)
    end
  end
end
