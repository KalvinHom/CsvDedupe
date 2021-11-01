defmodule CSVDedupe.PhoneDeduperTest do
  use ExUnit.Case
  alias CSVDedupe.Deduper.{PhoneDeduper, ParsedData}
  import CSVDedupeTest.Fixtures

  @columns [:first_name, :last_name, :email, :phone]

  describe "testing phone dedupe" do
    test "blank phone returns back the data whole" do
      no_phone = fixture(%{phone: ""})
      no_phone2 = fixture(%{phone: ""})

      result = PhoneDeduper.dedupe(%ParsedData{}, no_phone, @columns)
      %ParsedData{unique_phones: unique_phones, parsed_rows: parsed_rows} = result
      assert(Map.get(parsed_rows, 0) == no_phone)
      assert(unique_phones == %{})

      # second record with no email gets prepended
      %ParsedData{unique_phones: unique_phones, parsed_rows: parsed_rows} =
        PhoneDeduper.dedupe(result, no_phone2, @columns)

      assert(Map.get(parsed_rows, 1) == no_phone2)
      assert(unique_phones == %{})
    end

    test "non blank phone gets added by phone key and does not get added to nophone list" do
      with_phone = fixture(%{phone: "(123)456-7890"})
      key = PhoneDeduper.clean_number(with_phone.phone)

      # record with email doesn't get added to list
      %ParsedData{unique_phones: unique_phones, parsed_rows: parsed_rows} =
        PhoneDeduper.dedupe(%ParsedData{}, with_phone, @columns)

      assert(Map.get(parsed_rows, 0) == with_phone)
      assert(Map.get(unique_phones, key) == 0)
    end

    test "identical duplicate phones" do
      with_phone = fixture(%{phone: "(123)456-7890"})
      with_phone2 = fixture(%{phone: "(123) 456-7890"})
      key = PhoneDeduper.clean_number(with_phone.phone)

      %ParsedData{unique_phones: unique_phones, parsed_rows: parsed_rows} =
        %ParsedData{}
        |> PhoneDeduper.dedupe(with_phone, @columns)
        |> PhoneDeduper.dedupe(with_phone2, @columns)

      assert(Map.get(parsed_rows, 0) == with_phone)
      assert(Map.get(unique_phones, key) == 0)
    end

    test "duplicate phone numbers when one has symbols" do
      with_phone = fixture(%{phone: "123 456 7890"})
      with_phone2 = fixture(%{phone: "(123) 456-7890"})
      key = PhoneDeduper.clean_number(with_phone.phone)

      %ParsedData{unique_phones: unique_phones, parsed_rows: parsed_rows} =
        %ParsedData{}
        |> PhoneDeduper.dedupe(with_phone, @columns)
        |> PhoneDeduper.dedupe(with_phone2, @columns)

      assert(Map.get(unique_phones, key) == 0)
      assert(Map.get(parsed_rows, 0) == with_phone)
    end

    test "blank data from first record gets filled in with the duplicate's" do
      with_phone = fixture(%{phone: "123 456 7890", first_name: ""})
      with_phone2 = fixture(%{phone: "123 456 7890"})
      key = PhoneDeduper.clean_number(with_phone.phone)

      %ParsedData{unique_phones: unique_phones, parsed_rows: parsed_rows} =
        %ParsedData{}
        |> PhoneDeduper.dedupe(with_phone, @columns)
        |> PhoneDeduper.dedupe(with_phone2, @columns)

      assert(Map.get(parsed_rows, 0).first_name == with_phone2.first_name)
    end
  end
end
