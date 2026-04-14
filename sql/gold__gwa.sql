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
course_info as (
	select
		id,
		course_code,
		units
	from silver.Courses
),
final as (
	select
		g.student_number as student_number,
		course_code,
		grade,
		full_name,
		units,
		g.*
	from student_course_grade g
	join student_info s
	  on g.student_number = s.student_number
	join course_info c
	  on g.course_id = c.id
) select * from final limit 5;

select
  s.name,
  g.campus_id,
  sum(grade * unit_taken) / sum(
    case
      when cast(grade as decimal) is 0
	  then 0
	  else unit_taken
    end
  ) as weighted_grade,
  sum(
    case
	  when cast(grade as decimal) is 0
	  then 0
	  else unit_taken
	end
  ) as units_earned
from bronze.grades g
join bronze.students s
  on g.campus_id = s.campus_id
where status like 'active'
  and course_code not like '%pe%'
  and course_code not like '%nstp%'
group by g.campus_id;
