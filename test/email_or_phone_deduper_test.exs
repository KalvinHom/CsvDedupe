defmodule CSVDedupe.EmailOrPhoneDeduperTest do
  use ExUnit.Case
  alias CSVDedupe.Deduper.{EmailOrPhoneDeduper, PhoneDeduper}
  alias CSVDedupe.Deduper.ParsedData
  import CSVDedupeTest.Fixtures

  @columns [:first_name, :last_name, :email, :phone]

  describe "testing email or phone dedupe" do
    test "data does not have phone or email" do
      blank_data = fixture(%{email: "", phone: ""})

      %ParsedData{
        parsed_rows: parsed_rows,
        unique_emails: unique_emails,
        unique_phones: unique_phones
      } = EmailOrPhoneDeduper.dedupe(%ParsedData{}, blank_data, @columns)

      assert(Map.get(parsed_rows, 0) == blank_data)
      assert(unique_emails == %{})
      assert(unique_phones == %{})
    end
  end

  test "neither email or phone match an existing record" do
    row = fixture()

    %ParsedData{
      parsed_rows: parsed_rows,
      unique_emails: unique_emails,
      unique_phones: unique_phones
    } = EmailOrPhoneDeduper.dedupe(%ParsedData{}, row, @columns)

    assert(Map.get(parsed_rows, 0) == row)
    assert(Map.get(unique_emails, row.email) == 0)
    assert(Map.get(unique_phones, PhoneDeduper.clean_number(row.phone)) == 0)
  end

  test "both email and phone matches existing record" do
    row = fixture(%{email: "kalvin.hom@gmail.com", phone: "123-456-7890"})
    row2 = fixture(%{email: "kalvin.hom@gmail.com", phone: "123-456-7890"})

    %ParsedData{
      parsed_rows: parsed_rows,
      unique_emails: unique_emails,
      unique_phones: unique_phones
    } =
      %ParsedData{}
      |> EmailOrPhoneDeduper.dedupe(row, @columns)
      |> EmailOrPhoneDeduper.dedupe(row2, @columns)

    assert(Map.get(parsed_rows, 0) == row)
    assert(is_nil(Map.get(parsed_rows, 1)))

    assert(Map.get(unique_emails, row.email) == 0)
    assert(Map.get(unique_phones, PhoneDeduper.clean_number(row.phone)) == 0)
  end

  test "email matches, and existing data does not have phone" do
    row = fixture(%{email: "kalvin.hom@gmail.com", phone: ""})
    row2 = fixture(%{email: "kalvin.hom@gmail.com", phone: "123-456-7890"})

    %ParsedData{
      parsed_rows: parsed_rows,
      unique_emails: unique_emails,
      unique_phones: unique_phones
    } =
      %ParsedData{}
      |> EmailOrPhoneDeduper.dedupe(row, @columns)
      |> EmailOrPhoneDeduper.dedupe(row2, @columns)

    assert(Map.get(parsed_rows, 0).phone == row2.phone)
    assert(Map.get(unique_emails, row.email) == 0)
    assert(Map.get(unique_phones, PhoneDeduper.clean_number(row2.phone)) == 0)
  end

  test "email matches, and new data does not have phone" do
    row = fixture(%{email: "kalvin.hom@gmail.com", phone: "123-456-7890"})
    row2 = fixture(%{email: "kalvin.hom@gmail.com", phone: ""})

    %ParsedData{
      parsed_rows: parsed_rows,
      unique_emails: unique_emails,
      unique_phones: unique_phones
    } =
      %ParsedData{}
      |> EmailOrPhoneDeduper.dedupe(row, @columns)
      |> EmailOrPhoneDeduper.dedupe(row2, @columns)

    assert(Map.get(parsed_rows, 0).phone == row.phone)
    assert(Map.get(unique_emails, row.email) == 0)
    assert(Map.get(unique_phones, PhoneDeduper.clean_number(row.phone)) == 0)
  end

  test "email matches, but new phone differs from existing phone" do
    row = fixture(%{email: "kalvin.hom@gmail.com", phone: "123-456-7890"})
    row2 = fixture(%{email: "kalvin.hom@gmail.com", phone: "999-999-9999"})

    %ParsedData{
      parsed_rows: parsed_rows,
      unique_emails: unique_emails,
      unique_phones: unique_phones
    } =
      %ParsedData{}
      |> EmailOrPhoneDeduper.dedupe(row, @columns)
      |> EmailOrPhoneDeduper.dedupe(row2, @columns)

    assert(Map.get(parsed_rows, 0).phone == row.phone)
    assert(Map.get(unique_emails, row.email) == 0)
    assert(Map.get(unique_phones, PhoneDeduper.clean_number(row.phone)) == 0)
    assert(is_nil(Map.get(unique_phones, PhoneDeduper.clean_number(row2.phone))))
  end

  test "phone matches, and existing data does not have email" do
    row = fixture(%{email: "", phone: "123-456-7890"})
    row2 = fixture(%{email: "kalvin.hom@gmail.com", phone: "123-456-7890"})

    %ParsedData{
      parsed_rows: parsed_rows,
      unique_emails: unique_emails,
      unique_phones: unique_phones
    } =
      %ParsedData{}
      |> EmailOrPhoneDeduper.dedupe(row, @columns)
      |> EmailOrPhoneDeduper.dedupe(row2, @columns)

    assert(Map.get(parsed_rows, 0).email == row2.email)
    assert(Map.get(unique_emails, row2.email) == 0)
    assert(Map.get(unique_phones, PhoneDeduper.clean_number(row.phone)) == 0)
  end

  test "phone matches, but new email differs from existing" do
    row = fixture(%{email: "kalvin.hom@gmail.com", phone: "123-456-7890"})
    row2 = fixture(%{email: "kalvin@gmail.com", phone: "123-456-7890"})

    %ParsedData{
      parsed_rows: parsed_rows,
      unique_emails: unique_emails,
      unique_phones: unique_phones
    } =
      %ParsedData{}
      |> EmailOrPhoneDeduper.dedupe(row, @columns)
      |> EmailOrPhoneDeduper.dedupe(row2, @columns)

    assert(Map.get(parsed_rows, 0).email == row.email)
    assert(Map.get(unique_emails, row.email) == 0)
    assert(is_nil(Map.get(unique_emails, row2.email)))
    assert(Map.get(unique_phones, PhoneDeduper.clean_number(row.phone)) == 0)
  end

  test "phone matches, and new data does not have email" do
    row = fixture(%{email: "kalvin.hom@gmail.com", phone: "123-456-7890"})
    row2 = fixture(%{email: "", phone: "123-456-7890"})

    %ParsedData{
      parsed_rows: parsed_rows,
      unique_emails: unique_emails,
      unique_phones: unique_phones
    } =
      %ParsedData{}
      |> EmailOrPhoneDeduper.dedupe(row, @columns)
      |> EmailOrPhoneDeduper.dedupe(row2, @columns)

    assert(Map.get(parsed_rows, 0).email == row.email)
    assert(Map.get(unique_emails, row.email) == 0)
    assert(is_nil(Map.get(unique_emails, row2.email)))
    assert(Map.get(unique_phones, PhoneDeduper.clean_number(row.phone)) == 0)
  end
end
