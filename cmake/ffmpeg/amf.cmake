CPMGetPackage(amf)
install(FILES ${amf_SOURCE_DIR}/LICENSE.txt
        DESTINATION ${FFMPEG_INSTALL_PREFIX}/share/licenses/amf)

set(AMF_TARGET_DIR ${CMAKE_CURRENT_BINARY_DIR}/usr/local/include/AMF)
add_custom_target(amf ALL
        COMMAND ${CMAKE_COMMAND} -E copy_directory
            "${amf_SOURCE_DIR}/amf/public/include"
            "${AMF_TARGET_DIR}"
        COMMENT "Copying AMF headers"
)
add_dependencies(${CMAKE_PROJECT_NAME} amf)
install(DIRECTORY ${AMF_TARGET_DIR}
        DESTINATION ${FFMPEG_INSTALL_PREFIX}/include
)
