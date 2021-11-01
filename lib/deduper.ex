defmodule CSVDedupe.Deduper do
  alias CSVDedupe.Deduper.{EmailDeduper, PhoneDeduper, EmailOrPhoneDeduper, ParsedData}

  @moduledoc """
  Takes in a CSV file and dedupe type, returns a CSV without duplicates
  """

  @columns [:first_name, :last_name, :email, :phone]
  def main(args) do
    {opts, _, _} =
      OptionParser.parse(args,
        strict: [file: :string, strategy: :string],
        aliases: [f: :file, s: :strategy]
      )

    dedupe(Keyword.get(opts, :file), Keyword.get(opts, :strategy))
  end

  defp dedupe(file, strategy) when is_nil(file) or is_nil(strategy),
    do: IO.puts("Please include --file and --strategy arguments")

  defp dedupe(_file, strategy)
       when strategy != "email" and strategy != "phone" and strategy != "email_or_phone",
       do: IO.puts("Pleae input a valid strategy: email, phone, email_or_phone")

  defp dedupe(file, strategy) do
    file
    |> File.stream!()
    |> remove_header_row()
    |> Enum.reduce(%ParsedData{}, fn row, acc ->
      row
      |> String.trim()
      |> dedupe_row(acc, strategy)
      |> IO.inspect()
    end)
  end

  # skip blank lines
  defp dedupe_row("", kept_rows, _strategy), do: kept_rows

  defp dedupe_row(row, kept_rows, strategy) do
    row
    |> String.split(",")
    |> build_row()
    |> process_row(kept_rows, strategy)
  end

  defp process_row(row, kept_rows, "email"),
    do: EmailDeduper.dedupe(kept_rows, row, @columns)

  defp process_row(row, kept_rows, "phone"),
    do: PhoneDeduper.dedupe(kept_rows, row, @columns)

  defp process_row(row, kept_rows, "email_or_phone"),
    do: EmailOrPhoneDeduper.dedupe(kept_rows, row, @columns)

  defp build_row(row) do
    row
    |> Enum.with_index()
    |> Enum.reduce(%{}, fn {elem, index}, acc ->
      Map.put(acc, Enum.at(@columns, index), String.trim(elem))
    end)
  end

  defp remove_header_row(stream) do
    Stream.drop(stream, 1)
  end
end
