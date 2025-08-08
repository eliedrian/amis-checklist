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
    raw_course_id,
    sais_course_id
)
SELECT
    title,
    description,
    units,
    course_code,
    course_id,
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
JOIN silver.Courses c ON g.course_id = c.sais_course_id;

INSERT INTO silver.Offerings (
    term,
    course_id,
    section,
    raw_class_id
)
SELECT
    term_id,
    co.id,
    section,
    cl.id
FROM bronze.Classes cl
JOIN silver.Courses co
  ON cl.course_id = co.raw_course_id;

.read silver__offering_schedules.sql
