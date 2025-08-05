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
    return (s['campus_id'], s['email'],
            s['last_name'], s['first_name'], s['middle_name'], s['avatar'])

def grade_tuple(g):
    return (g['term'], g['course_id'], g['grade'], g['campus_id'])

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
                (student_number, email, last_name, first_name, middle_name, avatar) \
                VALUES (?, ?, ?, ?, ?, ?)', list(map(student_tuple, data)))

    case 'grades':
        cur.executemany('INSERT OR IGNORE INTO Grades \
                (term, course_id, grade, student_number) \
                VALUES (?, ?, ?, ?)', list(map(grade_tuple, data)))

con.commit()
con.close()
