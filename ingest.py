import argparse
import sqlite3
import json

parser = argparse.ArgumentParser('ingest.py')
parser.add_argument('--db', help='Path to an sqlite3 database.')
parser.add_argument('type', choices=['students', 'grades'], help='Type of data to ingest.')
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

con.commit()
con.close()
