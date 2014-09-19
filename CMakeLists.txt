cmake_minimum_required(VERSION 2.6)
include(cmake/Utilities.cmake)

project(CascLib)
set(PROJECT_VERSION 1.0.0)
set(PROJECT_INTERFACE_REVISION 1)

set(PUBLIC_HEADERS
    src/CascLib.h
    src/CascPort.h
)

set(CASCLIB_EXPORTS_FILE src/CascLib.def)

if(WIN32 AND MSVC)
    option(WITH_UNICODE    "Compile with Unicode support (Windows-only)" ON)
    option(WITH_STATIC_CRT "Link a static CRT library (Windows-only)"    OFF)
endif()
option(STATIC_LIBRARY  "Compile static linked library" OFF)
option(TEST_PROGRAM    "Compile Test application"      OFF)

set(HEADER_FILES
    ${PUBLIC_HEADERS}
    src/CascCommon.h
    src/CascMndxRoot.h
    src/common/Common.h
    src/common/FileStream.h
    src/common/ListFile.h
    src/common/Map.h
    src/jenkins/lookup.h
)

set(SRC_FILES
    src/common/Common.cpp
    src/common/Directory.cpp
    src/common/FileStream.cpp
    src/common/ListFile.cpp
    src/common/Map.cpp
    src/jenkins/lookup3.c
    src/CascBuildCfg.cpp
    src/CascCommon.cpp
    src/CascDecompress.cpp
    src/CascDumpData.cpp
    src/CascFindFile.cpp
    src/CascMndxRoot.cpp
    src/CascOpenFile.cpp
    src/CascOpenStorage.cpp
    src/CascReadFile.cpp
)

set(TOMCRYPT_FILES
    src/libtomcrypt/src/hashes/hash_memory.c
    src/libtomcrypt/src/hashes/md5.c
    src/libtomcrypt/src/misc/crypt_argchk.c
    src/libtomcrypt/src/misc/crypt_hash_descriptor.c
    src/libtomcrypt/src/misc/crypt_hash_is_valid.c
    src/libtomcrypt/src/misc/crypt_libc.c
)

set(ZLIB_BZIP2_FILES
    src/zlib/adler32.c
    src/zlib/crc32.c
    src/zlib/inffast.c
    src/zlib/inflate.c
    src/zlib/inftrees.c
    src/zlib/zutil.c
)

set(TEST_SRC_FILES
    test/CascTest.cpp
)

add_definitions(-D_7ZIP_ST -DBZ_STRICT_ANSI)

set(HEADERS ${HEADER_FILES})

if(WIN32)
    if(MSVC)
        info("Using MSVC")
        
        # Lets generate a couple filters so that we can actually explore all
        # participating files from the Solution Explorer.
        #
        # We will start with the headers
        source_group("header" FILES ${HEADER_FILES})

        # Then we sort out the actual sources
        source_group("source" FILES ${SRC_FILES})
        source_group("source\\zlib" FILES ${ZLIB_BZIP2_FILES})
        source_group("source\\tomcrypt" FILES ${TOMCRYPT_FILES})
        
        add_definitions(-DWIN32)
        if(CMAKE_SIZEOF_VOID_P EQUAL 8)
            add_definitions(-DWIN64)
        endif()
        
        set(SRC_ADDITIONAL_FILES ${SRC_ADDITIONAL_FILES} ${CASCLIB_EXPORTS_FILE})
        
    else()
        info("Using mingw or cygwin")
        
    endif()
    
    set(SRC_ADDITIONAL_FILES ${SRC_ADDITIONAL_FILES} ${ZLIB_BZIP2_FILES} ${TOMCRYPT_FILES})
    set(LINK_LIBS wininet)
    set(CASCLIB_NAME CascLib)
    
elseif(APPLE)
    info("Using Mac OS X port")
    
    set(SRC_ADDITIONAL_FILES ${SRC_ADDITIONAL_FILES} ${TOMCRYPT_FILES})
    set(LINK_LIBS z bz2)
    set(CASCLIB_NAME casc)
    
elseif(${CMAKE_SYSTEM_NAME} STREQUAL Linux)
    info("Using Linux port")
    
    option(WITH_LIBTOMCRYPT "Use system LibTomCrypt library" OFF)
    if(WITH_LIBTOMCRYPT)
        set(LINK_LIBS z bz2 tomcrypt)
    else()
        set(LINK_LIBS z bz2)
        set(SRC_ADDITIONAL_FILES ${SRC_ADDITIONAL_FILES} ${TOMCRYPT_FILES})
    endif()
    
    set(CASCLIB_NAME casc)
    
endif()

if(STATIC_LIBRARY)
    add_static_library(CascLib ${CASCLIB_NAME} ${SRC_FILES} ${SRC_ADDITIONAL_FILES} ${HEADERS})
else()
    add_shared_library(CascLib ${CASCLIB_NAME} ${SRC_FILES} ${SRC_ADDITIONAL_FILES} ${HEADERS})
endif()

if(TEST_PROGRAM)
    add_program(casc_test ${TEST_SRC_FILES})
    target_link_libraries(casc_test CascLib)
endif()
