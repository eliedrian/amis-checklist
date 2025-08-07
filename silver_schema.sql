CREATE TABLE IF NOT EXISTS Courses (
    id INTEGER PRIMARY KEY,
    title TEXT,
    description TEXT,
    units INTEGER,
    course_code TEXT,
    raw_course_id INTEGER
);

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
    (4.0, '4.0', true),
    (5.0, '5.0', true),
    (-999.0, 'INC', false),
    (999.0, 'DRP', false);

CREATE TABLE IF NOT EXISTS Grades (
    id INTEGER PRIMARY KEY,
    term INTEGER NOT NULL,
    course_id INTEGER NOT NULL,
    grade TEXT NOT NULL,
    student_number TEXT NOT NULL,
    active BOOLEAN,
    UNIQUE(term, course_id, student_number, active) ON CONFLICT REPLACE,
    FOREIGN KEY(student_number) REFERENCES Students(student_number),
    FOREIGN KEY(grade) REFERENCES GradeValues(name),
    FOREIGN KEY(course_id) REFERENCES Courses(id)
);

CREATE TABLE IF NOT EXISTS Students (
    student_number PRIMARY KEY,
    email TEXT UNIQUE,
    last_name TEXT,
    first_name TEXT,
    middle_name TEXT,
    avatar TEXT
);

CREATE TABLE IF NOT EXISTS Offerings (
    id INTEGER PRIMARY KEY,
    term INTEGER,
    course_id INTEGER,
    section TEXT,
    FOREIGN KEY(course_id) REFERENCES Courses(id)
);

CREATE TABLE IF NOT EXISTS OfferingSchedules (
    id INTEGER PRIMARY KEY,
    offering_id INTEGER,
    day TEXT,
    start_time TEXT,
    end_time TEXT,
    FOREIGN KEY(offering_id) REFERENCES Offerings(id)
);

CREATE TABLE IF NOT EXISTS Enlistments (
    id INTEGER PRIMARY KEY,
    student_number TEXT,
    offering_id INTEGER,
    UNIQUE(student_number, offering_id) ON CONFLICT IGNORE,
    FOREIGN KEY(student_number) REFERENCES Students(student_number),
    FOREIGN KEY(offering_id) REFERENCES Offerings(id)
);

CREATE TABLE IF NOT EXISTS Faculty (
    id INTEGER PRIMARY KEY,
    email TEXT UNIQUE,
    last_name TEXT,
    first_name TEXT,
    middle_name TEXT,
    avatar TEXT
);

CREATE TABLE IF NOT EXISTS FacultyAssignments (
    id INTEGER PRIMARY KEY,
    faculty_id INTEGER,
    offering_id INTEGER,
    FOREIGN KEY(faculty_id) REFERENCES Faculty(id),
    FOREIGN KEY(offering_id) REFERENCES Offerings(id)
);
