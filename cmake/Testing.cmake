FIND_PROGRAM(MPD_BIN mpd)
IF(NOT MPD_BIN)
	MESSAGE(FATAL_ERROR "Binary 'mpd' is required for testing!")
ENDIF()

FIND_PROGRAM(GTESTER_BIN gtester)
IF(NOT GTESTER_BIN)
	MESSAGE(FATAL_ERROR "Binary 'gtester' is required for testing!")
ENDIF()

ADD_DEFINITIONS(-D MPD_BINARY="\\"${MPD_BIN}\\"")
SET_DIRECTORY_PROPERTIES(PROPERTIES COMPILE_DEFINITIONS G_LOG_DOMAIN="dynlist_tests")

ADD_LIBRARY(fixture SHARED fixture_gmpc.c fixture_mpd.c)
TARGET_LINK_LIBRARIES(fixture ${DEPS_LIBRARIES} ${LIBMPD_LIBRARIES})

MACRO(ADD_TEST_CONFIG target def file)
	SET(outfile "${PROJECT_BINARY_DIR}/tests/${file}")
	CONFIGURE_FILE(${file}.in ${outfile} @ONLY)

	SET_PROPERTY(TARGET ${target} APPEND PROPERTY COMPILE_DEFINITIONS "${def}=\"${outfile}\"")
ENDMACRO()

MACRO(ADD_TEST_DATA target test_name)
	ADD_TEST(${test_name} gtester -k --verbose ${target})
	SET_TESTS_PROPERTIES(${test_name} PROPERTIES PASS_REGULAR_EXPRESSION "PASS")
	SET_TESTS_PROPERTIES(${test_name} PROPERTIES FAIL_REGULAR_EXPRESSION "FAIL")

	SET_TARGET_PROPERTIES(${target} PROPERTIES COMPILE_DEFINITIONS "")
	TARGET_LINK_LIBRARIES(${target} dynlist fixture ${DEPS_LIBRARIES} ${LIBMPD_LIBRARIES})
ENDMACRO()
