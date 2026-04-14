insert or ignore into silver.Courses (
    title,
    description,
    units,
    course_code,
    raw_course_id,
    sais_course_id
)
select
    title,
    description,
    units,
    course_code,
    course_id,
    sais_course_id
from bronze.Courses;
