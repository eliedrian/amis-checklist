ifneq (,$(wildcard ./.env))
    include .env
    export
endif

ODIR=build
DATA_DIR=data

FILTERS_DIR=filters
FILTER=$(FILTERS_DIR)/filter.jq
USERS_FILTER=$(FILTERS_DIR)/users_filter.jq
STUDENTS_FILTER=$(FILTERS_DIR)/students_filter.jq
STUDENTS_JOIN_FILTER=$(FILTERS_DIR)/students_join_filter.jq
CLASSES_FILTER=$(FILTERS_DIR)/classes_filter.jq
COURSES_FILTER=$(FILTERS_DIR)/courses_filter.jq

RAW_STUDENT_GRADES=$(addprefix $(DATA_DIR)/student-grades,121-2021.json 122-2021.json 123-2021.json 124-2021.json 125-2021.json 125-2025.json)
STUDENT_IDS=student_ids.txt
STUDENT_IDS_JSON=$(ODIR)/student_ids.json
BRONZE_DB_NAME=bronze.db
BRONZE_DB_PATH=$(ODIR)/$(BRONZE_DB_NAME)
SILVER_DB_NAME=silver.db
SILVER_DB_PATH=$(ODIR)/$(SILVER_DB_NAME)

SILVER_SCHEMA_SQL=silver_schema.sql
BRONZE_SCHEMA_SQL=bronze_schema.sql
SILVER_SQL=silver.sql

GRADES_JSON=$(ODIR)/grades.json
_USERS_JSON=$(ODIR)/_users.jsonl
_STUDENTS_JSON=$(ODIR)/_students.jsonl
STUDENTS_JSON=$(ODIR)/students.json
CLASSES_JSON=$(ODIR)/classes.json
COURSES_JSON=$(ODIR)/courses.json

INIT_SQL=$(ODIR)/init.sql

RAW_USERS=$(wildcard $(DATA_DIR)/users*.json)
RAW_STUDENTS=$(wildcard $(DATA_DIR)/students*.json)
RAW_CLASSES=$(wildcard $(DATA_DIR)/classes*.json)
RAW_COURSES=$(wildcard $(DATA_DIR)/courses*.json)

INGEST_MARKER_STUDENTS=$(ODIR)/.ingested_students
INGEST_MARKER_GRADES=$(ODIR)/.ingested_grades
INGEST_MARKER_CLASSES=$(ODIR)/.ingested_classes
INGEST_MARKER_COURSES=$(ODIR)/.ingested_courses
SILVER_TARGET=$(ODIR)/.last_silver

TARGETS=database collectgrades collectstudents ingest silver

.phony: all clean collectgrades collectstudents query ingeststudents ingest ingestgrades ingestclasses ingestcourses silver

all: $(TARGETS)

clean:
	rm -r $(ODIR)

$(INIT_SQL):
	echo "ATTACH DATABASE '$(BRONZE_DB_PATH)' AS bronze;" > $@
	echo "ATTACH DATABASE '$(SILVER_DB_PATH)' AS silver;" >> $@

silver: $(SILVER_TARGET)

query: $(INIT_SQL)
	sqlite3 -table -header -init $<

ingest: ingeststudents ingestgrades ingestclasses ingestcourses

ingeststudents: $(INGEST_MARKER_STUDENTS)

ingestcourses: $(INGEST_MARKER_COURSES)

ingestgrades: $(INGEST_MARKER_GRADES)

ingestclasses: $(INGEST_MARKER_CLASSES)

$(SILVER_TARGET): $(INIT_SQL) $(SILVER_SQL)
	sqlite3 -init $< < $(SILVER_SQL)
	touch $@

$(INGEST_MARKER_COURSES): $(COURSES_JSON) | $(BRONZE_DB_PATH)
	python ingest.py --db $(BRONZE_DB_PATH) courses $(COURSES_JSON)
	touch $@

$(INGEST_MARKER_CLASSES): $(CLASSES_JSON) | $(BRONZE_DB_PATH)
	python ingest.py --db $(BRONZE_DB_PATH) classes $(CLASSES_JSON)
	touch $@

$(INGEST_MARKER_STUDENTS): $(STUDENTS_JSON) | $(BRONZE_DB_PATH)
	python ingest.py --db $(BRONZE_DB_PATH) students $(STUDENTS_JSON)
	touch $@

$(INGEST_MARKER_GRADES): $(GRADES_JSON) | $(BRONZE_DB_PATH)
	python ingest.py --db $(BRONZE_DB_PATH) grades $(GRADES_JSON)
	touch $@

$(ODIR):
	mkdir -p $(ODIR)

database: $(SILVER_DB_PATH) $(BRONZE_DB_PATH)

collectstudents: $(STUDENTS_JSON)

collectgrades: $(GRADES_JSON)

$(COURSES_JSON): $(COURSES_FILTER)
	jq -f $(COURSES_FILTER) -s $(RAW_COURSES) > $@

$(CLASSES_JSON): $(CLASSES_FILTER)
	jq -f $(CLASSES_FILTER) -s $(RAW_CLASSES) > $@

$(STUDENTS_JSON): $(_USERS_JSON) $(_STUDENTS_JSON) $(STUDENTS_JOIN_FILTER)
	jq -n --slurpfile users $(_USERS_JSON) --slurpfile students $(_STUDENTS_JSON) -f $(STUDENTS_JOIN_FILTER) > $@

$(_USERS_JSON): $(RAW_USERS) | $(ODIR)
	jq -f $(USERS_FILTER) -s $(RAW_USERS) -c > $@

$(_STUDENTS_JSON): $(RAW_STUDENTS) $(STUDENT_IDS_JSON) | $(ODIR)
	jq -f $(STUDENTS_FILTER) --slurpfile ids $(STUDENT_IDS_JSON) -s $(RAW_STUDENTS) -c > $@

$(BRONZE_DB_PATH): $(BRONZE_SCHEMA_SQL) | $(ODIR)
	sqlite3 $@ < $<

$(SILVER_DB_PATH): $(SILVER_SCHEMA_SQL) | $(ODIR)
	sqlite3 $@ < $<

$(STUDENT_IDS_JSON): $(STUDENT_IDS) | $(ODIR)
	jq -R -s -c 'split("\n") | map(select(length > 0))' $< > $@

$(GRADES_JSON): $(RAW_STUDENT_GRADES) $(STUDENT_IDS_JSON) $(FILTER) | $(ODIR)
	jq --argjson ids '$(shell cat $(STUDENT_IDS_JSON))' -f $(FILTER) -s $(RAW_STUDENT_GRADES) > $@

$(DATA_DIR)/student-grades%.json:
	./fetch_grades.sh -t $(word 1,$(subst -, ,$*)) -s $(word 2,$(subst -, ,$*)) -o $@ -n
