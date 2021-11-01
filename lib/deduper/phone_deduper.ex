defmodule CSVDedupe.Deduper.PhoneDeduper do
  alias CSVDedupe.Utils.MergeData
  alias CSVDedupe.Deduper.ParsedData

  # if there's no phone, we add it to the :nophone list
  def dedupe(%ParsedData{} = parsed_data, %{phone: phone} = row, _columns)
      when phone == "" do
    add_phone_to_list(parsed_data, row)
  end

  def dedupe(
        %ParsedData{unique_phones: unique_phones, cur_id: cur_id} = parsed_data,
        %{phone: phone} = row,
        columns
      ) do
    cleaned_phone = clean_number(phone)

    case Map.get(unique_phones, cleaned_phone) do
      nil ->
        unique_phones = Map.put(unique_phones, cleaned_phone, cur_id)

        parsed_data
        |> Map.put(:unique_phones, unique_phones)
        |> add_phone_to_list(row)

      match ->
        handle_duplicate_phone(parsed_data, row, match, columns)
    end
  end

  defp handle_duplicate_phone(%{parsed_rows: parsed_rows} = parsed_data, row, match, columns) do
    merged_record =
      parsed_rows
      |> Map.get(match)
      |> MergeData.run(row, columns)

    parsed_rows = Map.put(parsed_rows, match, merged_record)
    Map.put(parsed_data, :parsed_rows, parsed_rows)
  end

  def clean_number(phone) do
    regex = ~r/\s|\(|\)|\-\+/
    Regex.replace(regex, phone, "")
  end

  def add_phone_to_list(
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
