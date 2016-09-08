cmake_minimum_required(VERSION 3.0.0)
cmake_policy(SET CMP0042 OLD)

project(RtAudio VERSION 4.1.2)

include(CheckFunctionExists)

check_function_exists(gettimeofday HAVE_GETTIMEOFDAY)

set(DEFINITIONS)
set(DIRECTORIES)
set(LIBRARIES)
set(OPTIONS)
set(HEADERS RtAudio.h)
set(SOURCES RtAudio.cpp ${HEADERS})

if(CMAKE_BUILD_TYPE STREQUAL "Debug")
  list(APPEND DEFINITIONS __RTAUDIO_DEBUG__)
endif()

if(HAVE_GETTIMEOFDAY)
  list(APPEND DEFINITIONS HAVE_GETTIMEOFDAY)
endif()

if(APPLE)
  find_library(COREAUDIO_LIB CoreAudio)
  find_library(COREFOUNDATION_LIB CoreFoundation)
  list(APPEND DEFINITIONS __MACOSX_CORE__)
  list(APPEND LIBRARIES ${COREAUDIO_LIB} ${COREFOUNDATION_LIB})
endif()

if(WIN32)
  list(APPEND DEFINITIONS __WINDOWS_DS__ __WINDOWS_WASAPI__ __WINDOWS_ASIO__)
  list(APPEND DIRECTORIES "${CMAKE_CURRENT_SOURCE_DIR}/include")
  list(APPEND LIBRARIES dsound ksuser ole32 uuid winmm)
  list(APPEND ASIO_HEADERS
    include/asio.h
    include/asiodrivers.h
    include/asiodrvr.h
    include/asiolist.h
    include/asiosys.h
    include/ginclude.h
    include/iasiodrv.h
    include/iasiothiscallresolver.h
  )
  list(APPEND ASIO_SOURCES
    include/asio.cpp
    include/asiodrivers.cpp
    include/asiolist.cpp
    include/iasiothiscallresolver.cpp
  )
  list(APPEND SOURCES
    ${ASIO_SOURCES}
    ${ASIO_HEADERS}
  )
endif()

if(CMAKE_CXX_COMPILER_ID MATCHES "Clang")
  list(APPEND OPTIONS -Wall)
endif()

add_library(rtaudio_objlib OBJECT ${SOURCES})

set_target_properties(
  rtaudio_objlib
  PROPERTIES
    CXX_STANDARD 11
    COMPILE_DEFINITIONS "${DEFINITIONS}"
    COMPILE_OPTIONS "${OPTIONS}"
    INCLUDE_DIRECTORIES "${DIRECTORIES}"
)

add_library(rtaudio SHARED $<TARGET_OBJECTS:rtaudio_objlib>)
target_link_libraries(rtaudio PUBLIC ${LIBRARIES})
set_target_properties(rtaudio PROPERTIES DEBUG_POSTFIX "_d")

add_library(rtaudio_static STATIC $<TARGET_OBJECTS:rtaudio_objlib>)
target_link_libraries(rtaudio_static PUBLIC ${LIBRARIES})
set_target_properties(rtaudio_static PROPERTIES DEBUG_POSTFIX "_d")

install(
  TARGETS rtaudio rtaudio_static
  PUBLIC_HEADER DESTINATION ${INCLUDE_INSTALL_DIR}
  LIBRARY DESTINATION lib
  ARCHIVE DESTINATION lib
)

install(FILES ${HEADERS} DESTINATION include)
if(WIN32)
  install(FILES ${ASIO_HEADERS} DESTINATION include/asio)
endif()

if(EXISTS ${RTAUDIO_FIND_TEMPLATE_FILE})
  configure_file(
    "${RTAUDIO_FIND_TEMPLATE_FILE}"
    "${CMAKE_CURRENT_BINARY_DIR}/FindRtAudio.cmake"
    @ONLY
  )
  install(FILES "${CMAKE_CURRENT_BINARY_DIR}/FindRtAudio.cmake" DESTINATION cmake)
endif()
