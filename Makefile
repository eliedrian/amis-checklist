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
ENLISTMENTS_FILTER=$(FILTERS_DIR)/enlistments_filter.jq

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
ENLISTMENTS_JSON=$(ODIR)/enlistments.json

INIT_SQL=$(ODIR)/init.sql

RAW_USERS=$(DATA_DIR)/users.json
RAW_STUDENTS=$(addprefix $(DATA_DIR)/students,2021.json 2025.json)
RAW_CLASSES=$(addprefix $(DATA_DIR)/classes,121.json 122.json 123.json 124.json 125.json)
RAW_COURSES=$(addprefix $(DATA_DIR)/,courses.json)
RAW_ENLISTMENTS=$(addprefix $(DATA_DIR)/student-enlistments,1211-2021.json 1212-2021.json 1221-2021.json 1222-2021.json 1231-2021.json 1232-2021.json 1233-2021.json 1241-2021.json 1242-2021.json 1243-2021.json 1251-2021.json 1251-2025.json 1252-2021.json 1251-2025.json)

INGEST_MARKER_STUDENTS=$(ODIR)/.ingested_students
INGEST_MARKER_GRADES=$(ODIR)/.ingested_grades
INGEST_MARKER_CLASSES=$(ODIR)/.ingested_classes
INGEST_MARKER_COURSES=$(ODIR)/.ingested_courses
INGEST_MARKER_ENLISTMENTS=$(ODIR)/.ingested_enlistments
SILVER_TARGET=$(ODIR)/.last_silver

TARGETS=database collectgrades collectstudents ingest silver

.phony: all clean collectgrades collectstudents query ingeststudents ingest ingestgrades ingestclasses ingestcourses silver cleanbuild cleandata ingestenlistments

all: $(TARGETS)

cleanbuild:
	rm -r $(ODIR)

cleandata:
	rm $(RAW_STUDENT_GRADES)

clean: cleanbuild cleandata

$(INIT_SQL):
	echo "ATTACH DATABASE '$(BRONZE_DB_PATH)' AS bronze;" > $@
	echo "ATTACH DATABASE '$(SILVER_DB_PATH)' AS silver;" >> $@

silver: $(SILVER_TARGET)

query: $(INIT_SQL)
	sqlite3 -table -header -init $<

ingest: ingeststudents ingestgrades ingestclasses ingestcourses ingestenlistments

ingeststudents: $(INGEST_MARKER_STUDENTS)

ingestcourses: $(INGEST_MARKER_COURSES)

ingestgrades: $(INGEST_MARKER_GRADES)

ingestclasses: $(INGEST_MARKER_CLASSES)
	
ingestenlistments: $(INGEST_MARKER_ENLISTMENTS)

$(SILVER_TARGET): $(INIT_SQL) $(SILVER_SQL) $(INGEST_MARKER_STUDENTS) $(INGEST_MARKER_GRADES) $(INGEST_MARKER_CLASSES) $(INGEST_MARKER_COURSES) $(INGEST_MARKER_ENLISTMENTS)
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

$(INGEST_MARKER_ENLISTMENTS): $(ENLISTMENTS_JSON) | $(BRONZE_DB_PATH)
	python ingest.py --db $(BRONZE_DB_PATH) enlistments $(ENLISTMENTS_JSON)
	touch $@

$(ODIR):
	mkdir -p $(ODIR)

database: $(SILVER_DB_PATH) $(BRONZE_DB_PATH)

collectstudents: $(STUDENTS_JSON)

collectgrades: $(GRADES_JSON)

$(ENLISTMENTS_JSON): $(ENLISTMENTS_FILTER) $(RAW_ENLISTMENTS)
	jq -f $(ENLISTMENTS_FILTER) -s $(RAW_ENLISTMENTS) > $@

$(COURSES_JSON): $(COURSES_FILTER) $(RAW_COURSES)
	jq -f $(COURSES_FILTER) -s $(RAW_COURSES) > $@

$(CLASSES_JSON): $(CLASSES_FILTER) $(RAW_CLASSES)
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

$(DATA_DIR)/users.json:
	./fetch_users.sh -o $@ -n

$(DATA_DIR)/student-grades%.json:
	./fetch_grades.sh -t $(word 1,$(subst -, ,$*)) -s $(word 2,$(subst -, ,$*)) -o $@ -n

$(DATA_DIR)/students%.json:
	./fetch_students.sh -s $* -o $@ -n

$(DATA_DIR)/classes%.json:
	./fetch_classes.sh -t $* -o $@ -n

$(DATA_DIR)/courses.json:
	./fetch_courses.sh -o $@ -n

$(DATA_DIR)/student-enlistments%.json:
	./fetch_enlistments.sh -t $(word 1,$(subst -, ,$*)) -s $(word 2,$(subst -, ,$*)) -o $@ -n
