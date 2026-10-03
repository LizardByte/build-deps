# Verifies that a nested x265 build produced the expected static library and
# refreshes its timestamp, so the custom command that declares the library as
# its OUTPUT stays up to date. When X265_CHECK_DEPTH is set, it also checks
# that the library contains the 10-bit and 12-bit objects: x265_10bit and
# x265_12bit are the per-depth C++ namespaces, so a defined symbol containing
# either name proves the corresponding objects were merged.
#
# Required variables:
#   X265_LIBRARY - path of the library the nested build must have produced
#
# Optional variables:
#   X265_CHECK_DEPTH - enable the bit depth check
#   X265_NM          - symbol lister (nm) used for the bit depth check
#   X265_NM_OPTIONAL - allow skipping the check when nm is missing or broken

if(NOT DEFINED X265_LIBRARY OR NOT EXISTS "${X265_LIBRARY}")
    message(FATAL_ERROR "x265 did not produce the expected library: ${X265_LIBRARY}")
endif()

if(X265_CHECK_DEPTH)
    # Only defined symbols count: the 8-bit objects reference 10/12-bit symbols
    # as undefined entries, which must not be mistaken for merged archives.
    if(DEFINED X265_NM AND NOT "${X265_NM}" STREQUAL "")
        foreach(x265_nm_mode --defined-only -U)
            execute_process(
                    COMMAND "${X265_NM}" "${x265_nm_mode}" "${X265_LIBRARY}"
                    OUTPUT_VARIABLE x265_symbols
                    ERROR_VARIABLE x265_nm_error
                    RESULT_VARIABLE x265_nm_result
            )
            if(x265_nm_result EQUAL 0)
                break()
            endif()
        endforeach()

        if(NOT x265_nm_result EQUAL 0)
            if(X265_NM_OPTIONAL)
                message(WARNING "could not inspect ${X265_LIBRARY} with ${X265_NM}: ${x265_nm_error}")
            else()
                message(FATAL_ERROR "could not inspect ${X265_LIBRARY} with ${X265_NM}: ${x265_nm_error}")
            endif()
        else()
            foreach(x265_depth 10bit 12bit)
                if(NOT x265_symbols MATCHES "x265_${x265_depth}")
                    message(FATAL_ERROR
                            "the combined x265 library has no ${x265_depth} objects: ${X265_LIBRARY}")
                endif()
            endforeach()
        endif()
    elseif(X265_NM_OPTIONAL)
        message(WARNING "bit depth check skipped, no nm available for ${X265_LIBRARY}")
    else()
        message(FATAL_ERROR "the bit depth check requires nm for ${X265_LIBRARY}")
    endif()
endif()

file(TOUCH_NOCREATE "${X265_LIBRARY}")
