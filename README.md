## Usage

Populate relevant student numbers in `student_ids.txt`, one per line.

### Updating

Probably (for now) `make clean` and update `Makefile` to collect new data for new terms.

In the `Makefile`, add term prefixes `12x` for data from 202x-202y to lines with `addprefix`.

Some rules have to have the full term ID, such as the enlistments.
