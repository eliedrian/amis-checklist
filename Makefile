ODIR=build
DATA_DIR=data

FILTER=filter.jq
USERS_FILTER=users_filter.jq
STUDENTS_FILTER=students_filter.jq
STUDENTS_JOIN_FILTER=students_join_filter.jq

RAW_STUDENT_GRADES=$(wildcard $(DATA_DIR)/student-grades*.json)
STUDENT_IDS=student_ids.txt
STUDENT_IDS_JSON=$(ODIR)/student_ids.json
DB_NAME=data.db
DB_PATH=$(ODIR)/$(DB_NAME)

GRADES_JSON=$(ODIR)/grades.json
_USERS_JSON=$(ODIR)/_users.jsonl
_STUDENTS_JSON=$(ODIR)/_students.jsonl
STUDENTS_JSON=$(ODIR)/students.json

RAW_USERS=$(wildcard $(DATA_DIR)/users*.json)
RAW_STUDENTS=$(wildcard $(DATA_DIR)/students*.json)

INGEST_MARKER_STUDENTS=$(ODIR)/.ingested_students
INGEST_MARKER_GRADES=$(ODIR)/.ingested_grades

TARGETS=database collectgrades collectstudents ingest

.phony: all clean collectgrades collectstudents ingeststudents ingest ingestgrades

all: $(TARGETS)

clean:
	rm -r $(ODIR)

ingest: ingeststudents ingestgrades

ingeststudents: $(INGEST_MARKER_STUDENTS)

ingestgrades: $(INGEST_MARKER_GRADES)

$(INGEST_MARKER_STUDENTS): $(STUDENTS_JSON)
	python ingest.py --db $(DB_PATH) students $(STUDENTS_JSON)
	touch $@


$(INGEST_MARKER_GRADES): $(GRADES_JSON)
	python ingest.py --db $(DB_PATH) grades $(GRADES_JSON)
	touch $@

$(ODIR):
	mkdir -p $(ODIR)

database: $(DB_PATH)

collectstudents: $(STUDENTS_JSON)

collectgrades: $(GRADES_JSON)

$(STUDENTS_JSON): $(_USERS_JSON) $(_STUDENTS_JSON) $(STUDENTS_JOIN_FILTER)
	jq -n --slurpfile users $(_USERS_JSON) --slurpfile students $(_STUDENTS_JSON) -f $(STUDENTS_JOIN_FILTER) > $@

$(_USERS_JSON): $(RAW_USERS) | $(ODIR)
	jq -f $(USERS_FILTER) -s $(RAW_USERS) -c > $@

$(_STUDENTS_JSON): $(RAW_STUDENTS) $(STUDENT_IDS_JSON) | $(ODIR)
	jq -f $(STUDENTS_FILTER) --slurpfile ids $(STUDENT_IDS_JSON) -s $(RAW_STUDENTS) -c > $@

$(DB_PATH): | $(ODIR)
	sqlite3 $@ < schema.sql

$(STUDENT_IDS_JSON): $(STUDENT_IDS) | $(ODIR)
	jq -R -s -c 'split("\n") | map(select(length > 0))' $< > $@

$(GRADES_JSON): $(RAW_STUDENT_GRADES) $(STUDENT_IDS_JSON) $(FILTER) | $(ODIR)
	jq --argjson ids '$(shell cat $(STUDENT_IDS_JSON))' -f $(FILTER) -s $(RAW_STUDENT_GRADES) > $@
