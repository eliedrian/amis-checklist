delete from gold.Gwa;
insert into gold.Gwa (
	student_number,
	student_name,
	gwa,
	units_earned
)
with student_course_grade as (
	select
		student_number,
		course_id,
		grade
	from silver.Grades
	where active = 1
),
student_info as (
	select
		student_number,
		format('%s, %s %s', last_name, first_name, middle_name) as full_name
	from silver.Students
),
credited_course_info as (
	select
		id,
		course_code,
		units
	from silver.Courses
	where course_code not like '%pe%'
	and course_code not like '%nstp%'
),
final as (
	select
		g.student_number as student_number,
		full_name,
		sum(grade * units) / sum(
			case
			when cast(grade as decimal) is 0
				then 0
			else units
			end
		) as weighted_grade,
		sum(
			case
			when cast(grade as decimal) is 0
				then 0
			else units
			end
		) as units_earned
	from student_course_grade g
	join student_info s
	on g.student_number = s.student_number
	join credited_course_info c
	on g.course_id = c.id
	group by g.student_number
) select * from final;
