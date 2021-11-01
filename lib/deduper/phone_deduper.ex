defmodule CSVDedupe.Deduper.PhoneDeduper do
  alias CSVDedupe.Utils.{AddRowToList, HandleDuplicateRow}
  alias CSVDedupe.Deduper.ParsedData

  def dedupe(%ParsedData{} = parsed_data, %{phone: phone} = row, columns)
      when phone == "" do
    empty_row? = Enum.all?(columns, fn column -> Map.get(row, column) == "" end)

    case empty_row? do
      true -> parsed_data
      false -> AddRowToList.run(parsed_data, row)
    end
  end

  def dedupe(
        %ParsedData{cur_id: cur_id} = parsed_data,
        %{phone: phone} = row,
        columns
      ) do
    case get_matching_phone(parsed_data, phone) do
      nil ->
        parsed_data
        |> add_unique_phone(phone, cur_id)
        |> AddRowToList.run(row)

      match ->
        HandleDuplicateRow.run(parsed_data, row, match, columns)
    end
  end

  def get_matching_phone(%ParsedData{unique_phones: unique_phones}, phone) do
    cleaned_phone = clean_number(phone)
    Map.get(unique_phones, cleaned_phone)
  end

  def add_unique_phone(%ParsedData{unique_phones: unique_phones} = parsed_data, phone, id) do
    cleaned_phone = clean_number(phone)

    case cleaned_phone do
      "" ->
        parsed_data

      clean ->
        unique_phones = Map.put(unique_phones, clean, id)
        Map.put(parsed_data, :unique_phones, unique_phones)
    end
  end

  def clean_number(phone) do
    regex = ~r/\s|\(|\)|\-|\+/
    Regex.replace(regex, phone, "")
  end
end
