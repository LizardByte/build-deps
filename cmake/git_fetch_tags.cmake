# This macro fetches tags for the given git repository
# Arguments are path to git repository

# GIT_FETCH_TAGS: args = `repo_path`
macro(GIT_FETCH_TAGS repo_path)
    execute_process(
        COMMAND git -C "${CMAKE_CURRENT_SOURCE_DIR}/${repo_path}" fetch --tags --depth=1
        COMMAND_ERROR_IS_FATAL ANY
    )
endmacro()
