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
_USERS_JSON=$(ODIR)/_users.json
_STUDENTS_JSON=$(ODIR)/_students.json
STUDENTS_JSON=$(ODIR)/students.json

RAW_USERS=$(wildcard $(DATA_DIR)/users*.json)
RAW_STUDENTS=$(wildcard $(DATA_DIR)/students*.json)

TARGETS=database collectgrades collectstudents

.phony: all clean collectgrades collectstudents

all: $(TARGETS)

clean:
	rm -r $(ODIR)

$(ODIR):
	mkdir -p $(ODIR)

database: $(DB_PATH)

collectstudents: $(STUDENTS_JSON)

collectgrades: $(GRADES_JSON)

$(STUDENTS_JSON): $(_USERS_JSON) $(_STUDENTS_JSON) $(STUDENTS_JOIN_FILTER)
	jq -n --slurpfile users $< --slurpfile students $(_STUDENTS_JSON) -f $(STUDENTS_JOIN_FILTER) > $@

$(_USERS_JSON): $(RAW_USERS) | $(ODIR)
	jq -f $(USERS_FILTER) -s $< > $@

$(_STUDENTS_JSON): $(RAW_STUDENTS) | $(ODIR)
	jq -f $(STUDENTS_FILTER) -s $< > $@

$(DB_PATH): | $(ODIR)
	sqlite3 $@ < schema.sql

$(STUDENT_IDS_JSON): $(STUDENT_IDS) | $(ODIR)
	jq -R -s -c 'split("\n") | map(select(length > 0))' $< > $@

$(GRADES_JSON): $(RAW_STUDENT_GRADES) $(STUDENT_IDS_JSON) $(FILTER) | $(ODIR)
	jq --argjson ids '$(shell cat $<)' -f $(FILTER) -s $< > $@
