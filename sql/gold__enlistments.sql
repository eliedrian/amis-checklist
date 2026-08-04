delete from gold.Enlistments;
insert into gold.Enlistments (
	student_number,
	student_name,
	term,
	course_code,
	section,
	units
)
with enlistments as (
	select *
	from silver.enlistments e
	join silver.offerings o
	  on e.offering_id = o.id
	join silver.courses c
	  on o.course_id = c.id
),
student_names as (
	select
		student_number,
		format('%s, %s %s', last_name, first_name, middle_name) as student_name
	from silver.students
),
final as (
	select 
		e.student_number as student_number,
		student_name,
		term,
		course_code,
		section,
		units
	from enlistments e
	join student_names n
	  on e.student_number = n.student_number
)
select * from final
