defmodule CSVDedupeTest.Fixtures do
  @alpha 'abcdefghijklmnopqrstuvwxyz'
  @numeric '1234567890'
  def fixture(opts \\ %{})

  def fixture(opts) do
    %{
      first_name: random_name(),
      last_name: random_name(),
      email: random_email(),
      phone: random_phone()
    }
    |> Map.merge(opts)
  end

  defp random_email() do
    "#{random_name()}@gmail.com"
  end

  defp random_name() do
    num_chars = Enum.random(3..10)
    for _ <- 1..num_chars, into: "", do: <<Enum.random(@alpha)>>
  end

  defp random_phone() do
    for _ <- 1..10, into: "", do: <<Enum.random(@numeric)>>
  end
end
