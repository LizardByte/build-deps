# Runs an MRI script with the archiver used by the target toolchain. GNU ar,
# llvm-ar and the libarchive-based ar of the BSDs can merge static archives
# through MRI scripts, but they only read such scripts from stdin and CMake has
# no shell redirection, so the script is fed through execute_process INPUT_FILE.
#
# Required variables:
#   X265_AR         - archiver executable
#   X265_MRI_SCRIPT - MRI script to run; relative archive names inside the
#                     script are resolved against the current working directory

if(NOT DEFINED X265_AR OR "${X265_AR}" STREQUAL ""
        OR NOT DEFINED X265_MRI_SCRIPT OR "${X265_MRI_SCRIPT}" STREQUAL "")
    message(FATAL_ERROR "X265_AR and X265_MRI_SCRIPT must be set")
endif()

execute_process(COMMAND "${X265_AR}" -M
        INPUT_FILE "${X265_MRI_SCRIPT}"
        COMMAND_ERROR_IS_FATAL ANY
)
