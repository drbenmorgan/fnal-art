# Should pass and provide config output file for comparison in
# BasicOutputOptions_01_r against reference.
cet_test(BasicOutputOptions_01_w HANDBUILT
  TEST_EXEC art
  TEST_ARGS
  -o out.root
  --tmpdir /tmp
  -c /dev/null
  --debug-config=config.out
  TEST_PROPERTIES
  PASS_REGULAR_EXPRESSION "\\*\\* Config output to file")
config_ref_test(BasicOutputOptions_01
 OUTPUT_FILTERS DEFAULT ${filterOutputModule})

# Specified stream name with empty outputs.
cet_test(BasicOutputOptions_12_w HANDBUILT
  TEST_EXEC art
  TEST_ARGS
  -o myOut:out.root
  --tmpDir /tmp
  -c /dev/null
  --debug-config=config.out
  TEST_PROPERTIES
  PASS_REGULAR_EXPRESSION "Config output to file")
config_ref_test(BasicOutputOptions_12
 OUTPUT_FILTERS DEFAULT ${filterOutputModule})
########################################################################

# Must make sure that excluded paths that share modules with
# non-excluded paths do not cause problems.  It is sufficient for the
# job to finish successfully--i.e. no output need be checked for this
# test.
cet_test(ExcludedPaths_t HANDBUILT
  TEST_EXEC art
  TEST_ARGS -c excluded_paths_t.fcl
  DATAFILES fcl/excluded_paths_t.fcl)

cet_test(PruneConfig_t_01 HANDBUILT
  TEST_EXEC art
  TEST_ARGS -c prune_config_t_01.fcl --prune-config
  DATAFILES fcl/prune_config_t_01.fcl
  TEST_PROPERTIES WILL_FAIL TRUE)

cet_test(NonexistentPathCheck_01_t HANDBUILT
  TEST_EXEC art
  TEST_ARGS --rethrow-all -c NonexistentPathCheck_01.fcl
  DATAFILES fcl/NonexistentPathCheck_01.fcl
  TEST_PROPERTIES PASS_REGULAR_EXPRESSION "\n  ERROR: Unknown path x1 specified by user in trigger_paths.\n")

cet_test(NonexistentPathCheck_02_t HANDBUILT
  TEST_EXEC art
  TEST_ARGS --rethrow-all -c NonexistentPathCheck_02.fcl
  DATAFILES fcl/NonexistentPathCheck_02.fcl
  TEST_PROPERTIES PASS_REGULAR_EXPRESSION "\n  ERROR: Unknown path x1 specified by user in end_paths.\n  ERROR: Unknown path d6 specified by user in end_paths.\n")
