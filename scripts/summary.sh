#!/bin/bash
build_dir=build
init_sql="$build_dir/init.sql"

sqlite3 -table -header -init "$init_sql" -readonly ':memory:' <<EOF

.print === GWA ===
select student_name, gwa, units_earned from gold.gwa where student_number = '$1';
.print 
.print === Grades ===
select course_code, grade, term from gold.grades where student_number = '$1' order by term asc;
.print
.print === Notable grades ===
select course_code, grade, term from gold.grades where student_number = '$1' and (cast(grade as decimal) = 0 or grade >= 4.0) order by term asc;
.print
.print === Enlistments ===
select term, course_code, section, units from gold.enlistments where student_number = '$1' order by term asc;
.print
.print === UnitLoad ===
select term, units from gold.unitload where student_number = '$1' order by term asc;
.print
EOF
