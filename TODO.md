# TODO

- [x] mine student information
- [x] compile student info
- [ ] script data collection, take auth as env
- [x] design schema
- [ ] build gold tables
- [ ] collect faculty info
- [ ] collect enlistments

## GWA computation

```
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
```
