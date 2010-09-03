# CPack
SET(CPACK_PACKAGE_VERSION ${VERSION})
SET(CPACK_PACKAGE_VERSION_MAJOR ${VERSION_MAJOR})
SET(CPACK_PACKAGE_VERSION_MINOR ${VERSION_MINOR})
SET(CPACK_PACKAGE_VERSION_PATCH ${VERSION_PATCH})
SET(CPACK_PACKAGE_DESCRIPTION_SUMMARY "Dynamic Playlist for gmpc")
SET(CPACK_PACKAGE_VENDOR "André Klitzing")
SET(CPACK_RESOURCE_FILE_LICENSE "${PROJECT_SOURCE_DIR}/COPYING")
SET(CPACK_SOURCE_PACKAGE_FILE_NAME "${PROJECT_NAME}-${VERSION}" CACHE INTERNAL "tarball basename")
SET(CPACK_SOURCE_GENERATOR TGZ)
SET(CPACK_SOURCE_IGNORE_FILES "\\\\.hgignore" "\\\\.hgtags" "/\\\\.hg/")
INCLUDE(CPack)

IF(CMAKE_COMPILER_IS_GNUCC OR CMAKE_COMPILER_IS_GNUCXX)

	# LCov (http://ltp.sourceforge.net/coverage/lcov.php)
	FIND_PROGRAM(LCOV_BIN lcov)
	IF(LCOV_BIN)
		SET(LCOV_FILE "${PROJECT_BINARY_DIR}/coverage.info")
		SET(LCOV_GLOBAL_CMD ${LCOV_BIN} -q -o ${LCOV_FILE})
		SET(LCOV_CMD ${LCOV_GLOBAL_CMD} -c -d ${PROJECT_BINARY_DIR}${CMAKE_FILES_DIRECTORY} -d ${PROJECT_BINARY_DIR}/tests${CMAKE_FILES_DIRECTORY})
		SET(LCOV_RM_CMD ${LCOV_GLOBAL_CMD} -r ${LCOV_FILE} "*.gob" "*/include/*")

		ADD_CUSTOM_COMMAND(OUTPUT ${LCOV_FILE} COMMAND ${LCOV_CMD} COMMAND ${LCOV_RM_CMD})
		ADD_CUSTOM_TARGET(lcov COMMAND ${LCOV_BIN} -l ${LCOV_FILE} DEPENDS ${LCOV_FILE})

		FIND_PROGRAM(GENHTML_BIN genhtml)
		IF(GENHTML_BIN)
			SET(REPORT_DIR "${PROJECT_BINARY_DIR}/coverage.report")
			SET(GENHTML_CMD ${GENHTML_BIN} -q -p ${PROJECT_SOURCE_DIR} -o ${REPORT_DIR} ${LCOV_FILE})

			ADD_CUSTOM_COMMAND(OUTPUT ${REPORT_DIR} COMMAND ${GENHTML_CMD} DEPENDS ${LCOV_FILE})
			ADD_CUSTOM_TARGET(lcov.report DEPENDS ${REPORT_DIR})
		ENDIF()
	ENDIF()

ENDIF()

# CppCheck (http://cppcheck.sourceforge.net)
FIND_PROGRAM(CPPCHECK_BIN cppcheck)
IF(CPPCHECK_BIN)
	SET(XML_FILE "${PROJECT_BINARY_DIR}/cppcheck.xml")
	SET(CPPCHECK_CMD ${CPPCHECK_BIN} -a --enable=all ${SRC_DIR} ${TEST_DIR})

	ADD_CUSTOM_COMMAND(OUTPUT ${XML_FILE} COMMAND ${CPPCHECK_CMD} -q --xml 2> ${XML_FILE})
	ADD_CUSTOM_TARGET(cppcheck COMMAND ${CPPCHECK_CMD} -v)
	ADD_CUSTOM_TARGET(cppcheck.report DEPENDS ${XML_FILE})
ENDIF()

# CppNcss (http://cppncss.sourceforge.net)
FIND_PROGRAM(CPPNCSS_BIN cppncss)
IF(CPPNCSS_BIN)
	SET(XML_FILE "${PROJECT_BINARY_DIR}/cppncss.xml")
	SET(CPPNCSS_CMD ${CPPNCSS_BIN} -k -r -Mg_assert_cmpint -p="${PROJECT_SOURCE_DIR}/" ${SRC_DIR} ${TEST_DIR})

	ADD_CUSTOM_COMMAND(OUTPUT ${XML_FILE} COMMAND ${CPPNCSS_CMD} -x -f="${XML_FILE}")
	ADD_CUSTOM_TARGET(cppncss COMMAND ${CPPNCSS_CMD} -m=CCN,NCSS,function)
	ADD_CUSTOM_TARGET(cppncss.report DEPENDS ${XML_FILE})
ENDIF()

# pmccabe (http://parisc-linux.org/~bame/pmccabe/)
FIND_PROGRAM(PMCCABE_BIN pmccabe)
IF(PMCCABE_BIN)
	ADD_CUSTOM_TARGET(pmccabe COMMAND ${PMCCABE_BIN} -v ${SRC_DIR}/*.c ${TEST_DIR}/*.c)
ENDIF()
