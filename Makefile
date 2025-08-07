ODIR=build
DATA_DIR=data

FILTERS_DIR=filters
FILTER=$(FILTERS_DIR)/filter.jq
USERS_FILTER=$(FILTERS_DIR)/users_filter.jq
STUDENTS_FILTER=$(FILTERS_DIR)/students_filter.jq
STUDENTS_JOIN_FILTER=$(FILTERS_DIR)/students_join_filter.jq

RAW_STUDENT_GRADES=$(wildcard $(DATA_DIR)/student-grades*.json)
STUDENT_IDS=student_ids.txt
STUDENT_IDS_JSON=$(ODIR)/student_ids.json
BRONZE_DB_NAME=bronze.db
BRONZE_DB_PATH=$(ODIR)/$(BRONZE_DB_NAME)
SILVER_DB_NAME=silver.db
SILVER_DB_PATH=$(ODIR)/$(SILVER_DB_NAME)

GRADES_JSON=$(ODIR)/grades.json
_USERS_JSON=$(ODIR)/_users.jsonl
_STUDENTS_JSON=$(ODIR)/_students.jsonl
STUDENTS_JSON=$(ODIR)/students.json

INIT_SQL=$(ODIR)/init.sql

RAW_USERS=$(wildcard $(DATA_DIR)/users*.json)
RAW_STUDENTS=$(wildcard $(DATA_DIR)/students*.json)

INGEST_MARKER_STUDENTS=$(ODIR)/.ingested_students
INGEST_MARKER_GRADES=$(ODIR)/.ingested_grades

TARGETS=database collectgrades collectstudents ingest

.phony: all clean collectgrades collectstudents query ingeststudents ingest ingestgrades

all: $(TARGETS)

clean:
	rm -r $(ODIR)

$(INIT_SQL):
	echo "ATTACH DATABASE '$(BRONZE_DB_PATH)' AS bronze;" > $@
	echo "ATTACH DATABASE '$(SILVER_DB_PATH)' AS silver;" >> $@

query: $(INIT_SQL)
	sqlite3 -table -header -init $<

ingest: ingeststudents ingestgrades

ingeststudents: $(INGEST_MARKER_STUDENTS)

ingestgrades: $(INGEST_MARKER_GRADES)

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

$(STUDENTS_JSON): $(_USERS_JSON) $(_STUDENTS_JSON) $(STUDENTS_JOIN_FILTER)
	jq -n --slurpfile users $(_USERS_JSON) --slurpfile students $(_STUDENTS_JSON) -f $(STUDENTS_JOIN_FILTER) > $@

$(_USERS_JSON): $(RAW_USERS) | $(ODIR)
	jq -f $(USERS_FILTER) -s $(RAW_USERS) -c > $@

$(_STUDENTS_JSON): $(RAW_STUDENTS) $(STUDENT_IDS_JSON) | $(ODIR)
	jq -f $(STUDENTS_FILTER) --slurpfile ids $(STUDENT_IDS_JSON) -s $(RAW_STUDENTS) -c > $@

$(BRONZE_DB_PATH): | $(ODIR)
	sqlite3 $@ < bronze_schema.sql

$(SILVER_DB_PATH): | $(ODIR)
	sqlite3 $@ < schema.sql

$(STUDENT_IDS_JSON): $(STUDENT_IDS) | $(ODIR)
	jq -R -s -c 'split("\n") | map(select(length > 0))' $< > $@

$(GRADES_JSON): $(RAW_STUDENT_GRADES) $(STUDENT_IDS_JSON) $(FILTER) | $(ODIR)
	jq --argjson ids '$(shell cat $(STUDENT_IDS_JSON))' -f $(FILTER) -s $(RAW_STUDENT_GRADES) > $@
