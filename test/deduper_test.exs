defmodule CSVDedupe.DeduperTest do
  use ExUnit.Case
  alias CSVDedupe.Deduper

  @columns [:first_name, :last_name, :email, :phone]

  describe "testing deduper" do
    test "missing or incorrect params" do
      assert is_nil(Deduper.dedupe(nil, "email"))
      assert is_nil(Deduper.dedupe("test.csv", nil))
      assert is_nil(Deduper.dedupe("test.csv", "abc"))
    end

    test "dedupe runs for email only" do
      %{unique_emails: unique_emails, unique_phones: unique_phones, cur_id: cur_id} =
        Deduper.dedupe("./test/csv/test.csv", "email")

      assert(cur_id == 4)

      count_emails =
        unique_emails
        |> Map.keys()
        |> Enum.count()

      assert(count_emails == 3)
      assert(unique_phones == %{})
    end

    test "dedupe runs for phone only" do
      %{unique_emails: unique_emails, unique_phones: unique_phones, cur_id: cur_id} =
        Deduper.dedupe("./test/csv/test.csv", "phone")

      assert(cur_id == 4)

      count_phones =
        unique_phones
        |> Map.keys()
        |> Enum.count()

      assert(count_phones == 3)
      assert(unique_emails == %{})
    end

    test "dedupe runs for email or phone" do
      %{unique_emails: unique_emails, unique_phones: unique_phones, cur_id: cur_id} =
        Deduper.dedupe("./test/csv/test.csv", "email_or_phone")

      assert(cur_id == 3)

      count_phones =
        unique_phones
        |> Map.keys()
        |> Enum.count()

      assert(count_phones == 3)

      count_emails =
        unique_emails
        |> Map.keys()
        |> Enum.count()

      assert(count_emails == 2)
    end
  end
end
