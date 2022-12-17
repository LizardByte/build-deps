#
# This macro applies patch to git repository if patch is applicable
# Arguments are path to git repository and path to the git patch
#
macro(apply_git_patch REPO_PATH PATCH_PATH)
    execute_process(COMMAND git apply --check ${PATCH_PATH}
        WORKING_DIRECTORY ${REPO_PATH}
        RESULT_VARIABLE SUCCESS)

    if(${SUCCESS} EQUAL 0)
        message("Applying git patch ${PATCH_PATH} in ${REPO_PATH} repository")
        execute_process(COMMAND git apply ${PATCH_PATH}
            WORKING_DIRECTORY ${REPO_PATH}
            RESULT_VARIABLE SUCCESS)

        if(${SUCCESS} EQUAL 1)
            # We don't stop here because it can happen in case of parallel builds
            message(WARNING "\nError: failed to apply the patch patch: ${PATCH_PATH}\n")
        endif()
    endif()
endmacro()
