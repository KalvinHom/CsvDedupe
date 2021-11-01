# CSVDedupe

## What Defines a Match?

For this exercise, emails are considered a match if they are exactly the same.
While technically `kalvin.hom@gmail.com`, `kalvinhom@gmail.com`, and `kalvin.hom+kevala@gmail.com`
all resolve to the same email, the input difference is more likely to be purposeful, e.g email sharing.

For phone numbers, standard phone characters are ignored in matches.
(123) 456-7890 is equivalent to 123-456-7890 and 1234567890.
The following characters are stripped: `(`,`)`,`-`,`+`, and any `whitespace`. Any other characters
are left in place.

## Which duplicate row should be the source of truth?

Duplicate rows will attempt to be merged by filling in blank existing data.
Where there is a conflict in data, the earlier row's data takes precedence.
If the first row has blank data that the later row has, the later row's data will fill in the blanks.

## Resulting CSV

The final ordering of the CSV will not match the original.
The final phone numbers will look as the original CSV without any characters stripped.

## How to Run

`mix escript.build`

`/csv_dedupe --file ".test.csv" -s "email"`

## Performance Assumption

I am assuming that a company's employee system does not have so many records that storing
records in a hash will have memory and performance implications. If this becomes the case,
the data should be stored differently.

## Future Feature Improvements

A nice-to-have would be to return a second spreadsheet showing all merge conflicts, so
that it can be reviewed manually for mistakes.
