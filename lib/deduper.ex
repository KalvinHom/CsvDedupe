defmodule CSVDedupe.Deduper do
  alias CSVDedupe.Deduper.{EmailDeduper, PhoneDeduper, EmailOrPhoneDeduper, ParsedData}
  alias NimbleCSV.RFC4180, as: CSV

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

    filepath = "./dedupe_#{:os.system_time(:millisecond)}.csv"

    dedupe(Keyword.get(opts, :file), Keyword.get(opts, :strategy))
    |> write_to_file(filepath)
  end

  def dedupe(file, strategy) when is_nil(file) or is_nil(strategy) do
    IO.puts("Please include --file and --strategy arguments")
    nil
  end

  def dedupe(_file, strategy)
      when strategy != "email" and strategy != "phone" and strategy != "email_or_phone" do
    IO.puts("Pleae input a valid strategy: email, phone, email_or_phone")
    nil
  end

  def dedupe(file, strategy) do
    file
    |> File.stream!()
    |> remove_header_row()
    |> Enum.reduce(%ParsedData{}, fn row, acc ->
      row
      |> String.trim()
      |> dedupe_row(acc, strategy)
    end)
  end

  def write_to_file(nil, _filepath), do: nil

  def write_to_file(data, filepath) do
    File.touch!(filepath)
    file = File.open!(filepath, [:write])

    max_row_idx = data.cur_id - 1

    Enum.map(0..max_row_idx, fn idx ->
      data = Map.get(data.parsed_rows, idx)
      [data.first_name, data.last_name, data.email, data.phone]
    end)
    |> List.insert_at(0, ["FirstName", "LastName", "Email", "Phone"])
    |> CSV.dump_to_stream()
    |> Enum.each(&IO.binwrite(file, &1))

    File.close(file)
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
