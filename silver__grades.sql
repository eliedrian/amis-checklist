insert into silver.Grades (
    term,
    course_id,
    grade,
    student_number,
    active
)
select
    term,
    c.id,
    g.grade,
    g.campus_id,
    g.status like 'active'
from bronze.Grades g
join silver.Courses c on g.course_id = c.sais_course_id;
