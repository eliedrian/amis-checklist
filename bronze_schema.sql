CREATE TABLE IF NOT EXISTS Grades (
    id INTEGER PRIMARY KEY,
    sais_id INTEGER,
    campus_id TEXT,
    term INTEGER,
    section TEXT,
    unit_taken TEXT,
    course_id INTEGER,
    grade TEXT,
    college TEXT,
    grade_type TEXT,
    status TEXT,
    remarks TEXT,
    course_code TEXT,
    student_name TEXT
);

CREATE TABLE IF NOT EXISTS Students (
    id TEXT PRIMARY KEY,
    sais_id TEXT,
    last_name TEXT,
    first_name TEXT,
    middle_name TEXT,
    email TEXT,
    user_roles TEXT,
    tester BOOLEAN,
    created_at TEXT,
    updated_at TEXT,
    google_id TEXT,
    country_of_citizenship TEXT,
    type_of_residency TEXT,
    avatar TEXT,
    name TEXT,
    user_id TEXT,
    campus_id TEXT
);
