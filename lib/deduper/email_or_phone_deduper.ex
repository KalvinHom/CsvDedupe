defmodule CSVDedupe.Deduper.EmailOrPhoneDeduper do
  @moduledoc """
  """
  alias CSVDedupe.Deduper.{EmailDeduper, PhoneDeduper, ParsedData}
  alias CSVDedupe.Utils.AddRowToList

  def dedupe(
        %ParsedData{} = parsed_data,
        %{email: email, phone: phone} = row,
        _columns
      )
      when email == "" and phone == "" do
    AddRowToList.run(parsed_data, row)
  end

  def dedupe(
        %ParsedData{} = parsed_data,
        %{email: email, phone: phone} = row,
        columns
      )
      when is_nil(phone) do
    parsed_data = EmailDeduper.dedupe(parsed_data, row, columns)
    %ParsedData{unique_emails: unique_emails, parsed_rows: parsed_rows} = parsed_data
    # if data has phone number, update that map as well.
    key = Map.get(unique_emails, email)
    record = Map.get(parsed_rows, key)

    case record.phone do
      nil ->
        parsed_data

      phone ->
        PhoneDeduper.add_unique_phone(parsed_data, phone, key)
    end
  end

  def dedupe(
        %ParsedData{} = parsed_data,
        %{email: email, phone: phone} = row,
        columns
      )
      when is_nil(email) do
    parsed_data = PhoneDeduper.dedupe(parsed_data, row, columns)
    %ParsedData{unique_emails: unique_emails, parsed_rows: parsed_rows} = parsed_data
    # if data has email, update that map as well.
    key = PhoneDeduper.get_matching_phone(parsed_data, phone)
    record = Map.get(parsed_rows, key)

    case record.email do
      nil ->
        parsed_data

      email ->
        unique_emails = Map.put(unique_emails, email, key)
        Map.put(parsed_data, :unique_emails, unique_emails)
    end
  end

  def dedupe(
        parsed_data,
        row,
        columns
      ) do
    handle_email_dedupe(parsed_data, row, columns)
    |> handle_phone_dedupe(row, columns)
    |> handle_unique(row, columns)
  end

  defp handle_email_dedupe(
         %ParsedData{unique_emails: unique_emails} = parsed_data,
         %{email: email} = row,
         columns
       ) do
    case Map.get(unique_emails, email) do
      nil ->
        {:no_match, parsed_data}

      key ->
        parsed_data = EmailDeduper.dedupe(parsed_data, row, columns)
        %{phone: phone} = Map.get(parsed_data.parsed_rows, key)

        result =
          case phone do
            "" -> parsed_data
            phone -> PhoneDeduper.add_unique_phone(parsed_data, phone, key)
          end

        {:match, result}
    end
  end

  defp handle_phone_dedupe({:match, parsed_data}, _row, _columns), do: {:match, parsed_data}

  defp handle_phone_dedupe(
         {:no_match, %ParsedData{unique_emails: unique_emails} = parsed_data},
         %{phone: phone} = row,
         columns
       ) do
    case PhoneDeduper.get_matching_phone(parsed_data, phone) do
      nil ->
        {:no_match, parsed_data}

      key ->
        parsed_data = PhoneDeduper.dedupe(parsed_data, row, columns)
        %{email: email} = Map.get(parsed_data.parsed_rows, key)

        result =
          case email do
            "" ->
              parsed_data

            email ->
              unique_emails = Map.put(unique_emails, email, key)

              Map.put(parsed_data, :unique_emails, unique_emails)
          end

        {:match, result}
    end
  end

  defp handle_unique({:match, parsed_data}, _row, _columns), do: parsed_data

  defp handle_unique(
         {:no_match,
          %ParsedData{
            cur_id: cur_id
          } = parsed_data},
         %{phone: phone, email: email} = row,
         _columns
       ) do
    parsed_data
    |> EmailDeduper.add_unique_email(email, cur_id)
    |> PhoneDeduper.add_unique_phone(phone, cur_id)
    |> AddRowToList.run(row)
  end
end
