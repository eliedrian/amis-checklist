CREATE TABLE IF NOT EXISTS GradeValues (
    value REAL UNIQUE,
    name TEXT PRIMARY KEY,
    numeric BOOLEAN
);

INSERT OR IGNORE INTO GradeValues (value, name, numeric) VALUES
    (1.0, '1.0', true),
    (1.25, '1.25', true),
    (1.5, '1.5', true),
    (1.75, '1.75', true),
    (2.0, '2.0', true),
    (2.25, '2.25', true),
    (2.5, '2.5', true),
    (2.75, '2.75', true),
    (3.0, '3.0', true),
    (4.0, '4.0', false),
    (5.0, '5.0', true),
    (-999.0, 'INC', false),
    (999.0, 'DRP', false);

CREATE TABLE IF NOT EXISTS Grades (
    id INTEGER PRIMARY KEY,
    term INTEGER NOT NULL,
    course_id INTEGER NOT NULL,
    grade TEXT,
    student_number TEXT NOT NULL,
    FOREIGN KEY(student_number) REFERENCES Students(student_number),
    FOREIGN KEY(grade) REFERENCES GradeValues(value)
);

CREATE TABLE IF NOT EXISTS Students (
    id INTEGER PRIMARY KEY,
    student_number TEXT UNIQUE,
    email TEXT,
    last_name TEXT,
    first_name TEXT,
    middle_name TEXT,
    avatar TEXT
);
