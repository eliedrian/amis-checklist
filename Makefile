FILTER=filter.jq
INPUT=$(wildcard student-grades*.json)
STUDENT_IDS=student_ids.txt
STUDENT_IDS_JSON=student_ids.json
ODIR=build
DB_NAME=data.db
TARGETS=database collectgrades
GRADES_JSON=grades.json

.phony: all clean collectgrades

all: $(TARGETS)

clean:
	rm -r $(ODIR)

$(ODIR):
	mkdir -p $(ODIR)

database: $(ODIR)/$(DB_NAME)

collectgrades: $(ODIR)/$(GRADES_JSON)

$(ODIR)/$(DB_NAME): | $(ODIR)
	sqlite3 $(ODIR)/$(DB_NAME) < schema.sql

$(ODIR)/$(STUDENT_IDS_JSON): $(STUDENT_IDS) | $(ODIR)
	jq -R -s -c 'split("\n") | map(select(length > 0))' $< > $@

$(ODIR)/$(GRADES_JSON): $(ODIR)/$(STUDENT_IDS_JSON) $(INPUT) $(FILTER) | $(ODIR)
	jq --argjson ids '$(shell cat $<)' -f $(FILTER) -s $(INPUT) > $@
