delete from silver.Offerings;
insert into silver.Offerings (
    term,
    course_id,
    section,
    raw_class_id
)
select
    term_id,
    co.id,
    section,
    cl.id
from bronze.Classes cl
join silver.Courses co
  on cl.course_id = co.raw_course_id;
