insert or ignore into gold.grades (
		grade,
		course_code,
		term,
		student_number,
		student_name
) 
select
	g.grade as grade,
	c.course_code as course_code,
	g.term as term,
	g.student_number as student_number,
	format('%s, %s %s', s.last_name, s.first_name, s.middle_name) as student_name
from silver.grades g
join silver.courses c
on g.course_id = c.id
join silver.students s
on g.student_number = s.student_number
where active = true
