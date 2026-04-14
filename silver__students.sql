insert or ignore into silver.Students (
    student_number,
    email,
    last_name,
    first_name,
    middle_name,
    avatar
)
select
    campus_id,
    email,
    last_name,
    first_name,
    middle_name,
    avatar
from bronze.Students;
