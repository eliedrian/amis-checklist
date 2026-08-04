delete from gold.UnitLoad;
insert into gold.UnitLoad (
	student_number,
	student_name,
	term,
	units
)
with final as (
	select 
		student_number,
		student_name,
		term,
		sum(units) as units
	from gold.enlistments
	group by student_number, term
)
select * from final
