INSERT OR IGNORE INTO silver.Students (
    student_number,
    email,
    last_name,
    first_name,
    middle_name,
    avatar
)
SELECT
    campus_id,
    email,
    last_name,
    first_name,
    middle_name,
    avatar
FROM bronze.Students;

INSERT OR IGNORE INTO silver.Courses (
    title,
    description,
    units,
    course_code,
    raw_course_id
)
SELECT
    title,
    description,
    units,
    course_code,
    sais_course_id
FROM bronze.courses;

INSERT INTO silver.Grades (
    term,
    course_id,
    grade,
    student_number,
    active
)
SELECT
    term,
    c.id,
    g.grade,
    g.campus_id,
    g.status like 'active'
FROM bronze.Grades g
JOIN silver.Courses c ON g.course_id = c.raw_course_id;
