# Removes a nested x265 build directory when its configure arguments changed, so
# stale cache entries from removed -D options cannot survive. The applied
# fingerprint is recorded only after the build and its verification succeeded,
# so a failed attempt retries from a clean configure.
#
# Required variables:
#   X265_BUILD_DIR      - nested build directory to clean when out of date
#   X265_ARGUMENTS_FILE - current configure arguments fingerprint
#   X265_APPLIED_FILE   - fingerprint recorded after the last successful build

foreach(x265_required_var X265_BUILD_DIR X265_ARGUMENTS_FILE X265_APPLIED_FILE)
    if(NOT DEFINED ${x265_required_var} OR "${${x265_required_var}}" STREQUAL "")
        message(FATAL_ERROR "${x265_required_var} must be set")
    endif()
endforeach()

if(EXISTS "${X265_APPLIED_FILE}")
    file(READ "${X265_APPLIED_FILE}" _x265_applied_arguments)
else()
    set(_x265_applied_arguments "")
endif()
file(READ "${X265_ARGUMENTS_FILE}" _x265_current_arguments)

if(NOT "${_x265_applied_arguments}" STREQUAL "${_x265_current_arguments}")
    message(STATUS "x265 configure arguments changed, cleaning ${X265_BUILD_DIR}")
    file(REMOVE_RECURSE "${X265_BUILD_DIR}")
endif()
