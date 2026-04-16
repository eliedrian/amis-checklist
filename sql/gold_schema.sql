CREATE TABLE IF NOT EXISTS Grades (
    id INTEGER PRIMARY KEY,
    grade TEXT,
    course_code TEXT,
    term INTEGER,
    student_number TEXT,
	student_name TEXT
);

create table if not exists Gwa (
	id integer primary key,
	student_number text,
	student_name text,
	gwa real,
	units_earned integer
);

-- create view if not exists gwa (
--         name,
--         student_number,
--         grade,
--         units
-- ) as with students as (
--         select
--                 student_number,
--                 concat(last_name, ", ", first_name, " ", middle_name) as full_name
--         from silver.students
-- ),
-- counted_courses as (
--         select
--                 id
--         from silver.courses
--         where course_code not like '%pe%'
--         and course_code not like '%nstp%'
-- ),
-- grouped_grades as (
--         select
--         sum(grade * unit_taken) / sum(
--                 case
--                 when cast(grade as decimal) is 0
--                         then 0
--                 else unit_taken
--                 end
--         ) as weighted_grade,
--         sum(
--                 case
--                 when cast(grade as decimal) is 0
--                         then 0
--                 else unit_taken
--                 end
--         ) as units_earned
--         from silver.grades g
--         join counted_courses c
--         where g.course_id = c.id
-- ),
-- final as (
--         select
--                 full_name,
--                 student_number,
-- 
-- )
