macro(info)
    message(STATUS ${ARGN})
endmacro()

macro(warn)
    message(WARNING ${ARGN})
endmacro()

macro(error)
    message(SEND_ERROR ${ARGN})
endmacro()

macro(fatal)
    message(FATAL_ERROR ${ARGN})
endmacro()

macro(default_target_configuration target)
    target_link_libraries(${target} ${LINK_LIBS})
    
    if(${CMAKE_VERSION} VERSION_LESS "2.8")
        set_target_properties(${target} PROPERTIES
            ARCHIVE_OUTPUT_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/lib
            LIBRARY_OUTPUT_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/lib
            RUNTIME_OUTPUT_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/bin
        )
    else()
        set_target_properties(${target} PROPERTIES
            ARCHIVE_OUTPUT_DIRECTORY_DEBUG          ${CMAKE_CURRENT_SOURCE_DIR}/lib
            ARCHIVE_OUTPUT_DIRECTORY_RELEASE        ${CMAKE_CURRENT_SOURCE_DIR}/lib
            ARCHIVE_OUTPUT_DIRECTORY_RELWITHDEBINFO ${CMAKE_CURRENT_SOURCE_DIR}/lib
            ARCHIVE_OUTPUT_DIRECTORY_MINSIZEREL     ${CMAKE_CURRENT_SOURCE_DIR}/lib
            
            LIBRARY_OUTPUT_DIRECTORY_DEBUG          ${CMAKE_CURRENT_SOURCE_DIR}/lib
            LIBRARY_OUTPUT_DIRECTORY_RELEASE        ${CMAKE_CURRENT_SOURCE_DIR}/lib
            LIBRARY_OUTPUT_DIRECTORY_RELWITHDEBINFO ${CMAKE_CURRENT_SOURCE_DIR}/lib
            LIBRARY_OUTPUT_DIRECTORY_MINSIZEREL     ${CMAKE_CURRENT_SOURCE_DIR}/lib
            
            RUNTIME_OUTPUT_DIRECTORY_DEBUG          ${CMAKE_CURRENT_SOURCE_DIR}/bin
            RUNTIME_OUTPUT_DIRECTORY_RELEASE        ${CMAKE_CURRENT_SOURCE_DIR}/bin
            RUNTIME_OUTPUT_DIRECTORY_RELWITHDEBINFO ${CMAKE_CURRENT_SOURCE_DIR}/bin
            RUNTIME_OUTPUT_DIRECTORY_MINSIZEREL     ${CMAKE_CURRENT_SOURCE_DIR}/bin
        )
    endif()
    
    if(MSVC)
        if(WITH_UNICODE)
            get_target_property(pre_defs ${target} COMPILE_DEFINITIONS)
            set_target_properties(${target} PROPERTIES COMPILE_DEFINITIONS "${pre_defs};_UNICODE;UNICODE")
        endif()
    endif()
    
    if(NOT(STATIC_LIBRARY) AND APPLE)
        set_target_properties(${target} PROPERTIES FRAMEWORK true)
        set_target_properties(${target} PROPERTIES PUBLIC_HEADER ${PUBLIC_HEADERS})
        set_target_properties(${target} PROPERTIES LINK_FLAGS "-framework Carbon")
    endif()

    if(NOT(STATIC_LIBRARY))
        set_target_properties(${target} PROPERTIES VERSION ${PROJECT_VERSION})
        set_target_properties(${target} PROPERTIES SOVERSION ${PROJECT_API_REVISION})
    endif()
endmacro()

macro(init_target_name target name)
    if(MSVC)
        if(WITH_STATIC_CRT)
            set(libtype_suffix "S")
        else()
            set(libtype_suffix "D")
        endif()
        
        if(WITH_UNICODE)
            set(charset_suffix "U")
        else()
            set(charset_suffix "A")
        endif()
        
        if(${CMAKE_VERSION} VERSION_LESS "2.8")
            set_target_properties(${target} PROPERTIES
                DEBUG_OUTPUT_NAME          "${name}D${charset_suffix}${libtype_suffix}"
                RELEASE_OUTPUT_NAME        "${name}R${charset_suffix}${libtype_suffix}"
                RELWITHDEBINFO_OUTPUT_NAME "${name}R${charset_suffix}${libtype_suffix}"
                MINSIZEREL_OUTPUT_NAME     "${name}R${charset_suffix}${libtype_suffix}"
            )
        else()
            set_target_properties(${target} PROPERTIES
                OUTPUT_NAME_DEBUG          "${name}D${charset_suffix}${libtype_suffix}"
                OUTPUT_NAME_RELEASE        "${name}R${charset_suffix}${libtype_suffix}"
                OUTPUT_NAME_RELWITHDEBINFO "${name}R${charset_suffix}${libtype_suffix}"
                OUTPUT_NAME_MINSIZEREL     "${name}R${charset_suffix}${libtype_suffix}"
            )
        endif()
    else()
        set_target_properties(${target} PROPERTIES OUTPUT_NAME ${name})
    endif()
endmacro()

macro(add_static_library target_name output_name)
    add_library(${target_name} STATIC ${ARGN})
    default_target_configuration(${target_name})
    init_target_name(${target_name} ${output_name})
endmacro()

macro(add_shared_library target_name output_name)
    add_library(${target_name} SHARED ${ARGN})
    default_target_configuration(${target_name})
    init_target_name(${target_name} ${output_name})
endmacro()

macro(add_program target_name)
    add_executable(${target_name} ${ARGN})
    default_target_configuration(${target_name})
endmacro()
