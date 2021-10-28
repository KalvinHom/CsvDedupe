# CSVDedupe

## What Defines a Match?

For this exercise, emails are considered a match if they are exactly the same.
While technically `kalvin.hom@gmail.com`, `kalvinhom@gmail.com`, and `kalvin.hom+kevala@gmail.com`
all resolve to the same email, the input difference is more likely to be purposeful, e.g email sharing.

For phone numbers, standard phone characters are ignored in matches.
(123) 456-7890 is equivalent to 123-456-7890 and 1234567890.
The following characters are stripped: `(`,`)`,`-`,`+`, and any `whitespace`

## Which row should be the source of truth?

If both rows have data filled out, the earlier row's data will be kept.
If the first row has blank data that the later row has, the later row's data will fill in the blanks.
