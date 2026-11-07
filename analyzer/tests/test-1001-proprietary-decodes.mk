#
# Fork-only tests are numbered from 1001 so upstream's own names never reach them.
# This tests proprietary Mercury, Navico, Fusion and Victron (PGN, variant) decodes,
# one representative real-world frame each, grouped by manufacturer.
#
.PHONY: test1001
tests: test1001
test1001:
	$(ANALYZER) < pgn-boat-test.in > $(TEMPDIR)/pgn-boat-test.out -debug -q -fixtime pgn-boat-test 2> $(TEMPDIR)/pgn-boat-test.err
	diff $(TEMPDIR)/pgn-boat-test.out pgn-boat-test.out
	diff $(TEMPDIR)/pgn-boat-test.err pgn-boat-test.err
