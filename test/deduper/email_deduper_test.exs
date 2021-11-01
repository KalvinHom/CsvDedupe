defmodule CSVDedupe.Deduper.EmailDeduperTest do
  use ExUnit.Case
  alias CSVDedupe.Deduper.EmailDeduper
  alias CSVDedupe.Deduper.ParsedData
  import CSVDedupeTest.Fixtures

  @columns [:first_name, :last_name, :email, :phone]

  describe "testing email dedupe" do
    test "blank email returns back the data whole" do
      no_email = fixture(%{email: ""})
      no_email2 = fixture(%{email: ""})

      result = EmailDeduper.dedupe(%ParsedData{}, no_email, @columns)
      %ParsedData{unique_emails: unique_emails, parsed_rows: parsed_rows} = result
      assert(Map.get(parsed_rows, 0) == no_email)
      assert(unique_emails == %{})

      # second record with no email gets prepended
      %ParsedData{unique_emails: unique_emails, parsed_rows: parsed_rows} =
        EmailDeduper.dedupe(result, no_email2, @columns)

      assert(Map.get(parsed_rows, 1) == no_email2)
      assert(unique_emails == %{})
    end

    test "non blank email gets added by email key and does not get added to noemail list" do
      with_email = fixture(%{email: "kalvin.hom@gmail.com"})
      # record with email doesn't get added to list
      %ParsedData{unique_emails: unique_emails, parsed_rows: parsed_rows} =
        EmailDeduper.dedupe(%ParsedData{}, with_email, @columns)

      assert(Map.get(parsed_rows, 0) == with_email)
      assert(Map.get(unique_emails, with_email.email) == 0)
    end

    test "duplicate email row is discarded" do
      with_email = fixture(%{email: "kalvin.hom@gmail.com"})
      with_email2 = fixture(%{email: "kalvin.hom@gmail.com"})

      %ParsedData{unique_emails: unique_emails, parsed_rows: parsed_rows} =
        %ParsedData{}
        |> EmailDeduper.dedupe(with_email, @columns)
        |> EmailDeduper.dedupe(with_email2, @columns)

      assert(Map.get(parsed_rows, 0) == with_email)
      assert(Map.get(unique_emails, with_email.email) == 0)
    end

    test "blank data from first record gets filled in with the duplicate's" do
      with_email = fixture(%{email: "kalvin.hom@gmail.com", first_name: ""})
      with_email2 = fixture(%{email: "kalvin.hom@gmail.com"})

      %ParsedData{parsed_rows: parsed_rows} =
        %ParsedData{}
        |> EmailDeduper.dedupe(with_email, @columns)
        |> EmailDeduper.dedupe(with_email2, @columns)

      assert(Map.get(parsed_rows, 0).first_name == with_email2.first_name)
    end
  end
end
