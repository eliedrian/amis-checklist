import argparse
import sqlite3
import json

parser = argparse.ArgumentParser('ingest.py')
parser.add_argument('--db', help='Path to an sqlite3 database.')
parser.add_argument('type', choices=['students', 'grades', 'classes', 'courses'], help='Type of data to ingest.')
parser.add_argument('source', help='JSON data source.')
args = parser.parse_args()

con = sqlite3.connect(args.db)

def student_tuple(s):
    return (s['id'], s['sais_id'], s['last_name'], s['first_name'], s['last_name'],
        s['email'], s['user_roles'], s['tester'], s['created_at'], s['updated_at'],
        s['google_id'], s['country_of_citizenship'], s['type_of_residency'],
        s['avatar'], s['name'], s['user_id'], s['campus_id'])

def grade_tuple(g):
    return (g['id'], g['sais_id'], g['campus_id'], g['term'], g['section'],
            g['unit_taken'], g['course_id'], g['grade'], g['college'],
            g['grade_type'], g['status'], g['remarks'], g['course_code'],
            g['student_name'])

def course_tuple(c):
    return ( c['course_id'], c['sais_course_id'], c['title'], c['type'],
            c['description'], c['course_code'], c['sem_offered'], c['career'],
            int(c['units']), c['is_repeatable'], c['is_active'], c['campus'],
            c['equivalent'], c['is_multiple_enrollment'], c['subject'],
            c['course_number'], c['contact_hours'], c['grading'], c['tm_id'],
            c['acad_org'], c['acad_group'], c['created_at'], c['updated_at'],
            c['status'], c['is_academic'], c['course_code_title'],
            json.dumps(c['teaching_model']), json.dumps(c['requisites']))

def class_tuple(c):
    return (c['id'], c['course_code'], c['course_id'], c['term_id'],
            c['parent_class_id'], c['type'], c['date'], c['section'],
            c['time'], c['start_time'], c['end_time'], c['credit'],
            c['tm_id'], c['facility_id'], c['max_class_size'],
            c['reserved_count'], c['prerog_count'], c['active_class_size'],
            c['total_enlistment'], c['activity'], c['acad_org'], c['acad_group'],
            c['assoc'], c['class_nbr'], c['class_status'], c['consent_type'],
            c['hide_faculty'], c['is_partial_posting'], c['is_parent_class'],
            json.dumps(c['faculty_grades_assignments']), json.dumps(c['faculties']),
            json.dumps(c['class_dates']))

data = None

try:
    with open(args.source) as source:
        data = json.load(source)
except e:
    print('JSON load failure.')

cur = con.cursor()

match args.type:
    case 'students':
        cur.executemany('INSERT OR IGNORE INTO Students \
                (id, sais_id, last_name, first_name, middle_name, email, \
                user_roles, tester, created_at, updated_at, google_id, \
                country_of_citizenship, type_of_residency, avatar, name, \
                user_id, campus_id) \
                VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)',
                        list(map(student_tuple, data)))

    case 'grades':
        cur.executemany('INSERT OR IGNORE INTO Grades \
                (id, sais_id, campus_id, term, section, unit_taken, course_id, \
                grade, college, grade_type, status, remarks, course_code, student_name) \
                VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)',
                        list(map(grade_tuple, data)))

    case 'classes':
        cur.executemany('INSERT OR IGNORE INTO Classes \
                (id, course_code, course_id, term_id, parent_class_id, \
                type, date, section, time, start_time, end_time, credit, \
                tm_id, facility_id, max_class_size, reserved_count, \
                prerog_count, active_class_size, total_enlistment, activity, \
                acad_org, acad_group, assoc, class_nbr, class_status, \
                consent_type, hide_faculty, is_partial_posting, is_parent_class, \
                faculty_grades_assignments, faculties, class_dates) \
                VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, \
                ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)',
                       list(map(class_tuple, data)))

    case 'courses':
        query = """
INSERT OR IGNORE INTO Courses (
    course_id, sais_course_id, title, type, description, course_code,
    sem_offered, career, units, is_repeatable, is_active, campus, equivalent,
    is_multiple_enrollment, subject, course_number, contact_hours, grading,
    tm_id, acad_org, acad_group, created_at, updated_at, status, is_academic,
    course_code_title, teaching_model, requisites)
VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
        """
        cur.executemany(query, list(map(course_tuple, data)))

con.commit()
con.close()
