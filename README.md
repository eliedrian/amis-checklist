## Usage

Populate relevant student numbers in `student_ids.txt`, one per line.

And set `API_TOKEN` under `.env`.
The token is obtained from the URL as a query parameter after logging into AMIS.

Run `make` to fetch and generate tables.

`make clean` to remove generated files.

`make cleanbuild` to remove tables only.

### Updating

Probably (for now) `make clean` and update `Makefile` to collect new data for new terms.

In the `Makefile`, add term prefixes `12x` for data from 202x-202y to lines with `addprefix`.

Some rules have to have the full term ID, such as the enlistments.
