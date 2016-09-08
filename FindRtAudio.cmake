## FindRtAudio
## ----------
##
## Try to find the Lib RtAudio.
##
## Once done this will define:
## - Variables:
##   * `RTAUDIO_FOUND` - System has RtAudio.
##   * `RTAUDIO_INCLUDE_DIR` - The RtAudio include directory.
##   * `RTAUDIO_LIBRARY` - The libraries needed to use RtAudio.
##   * `RTAUDIO_LIBRARY_DEBUG` - The libraries needed to use RtAudio in Debug config.
##   * `RTAUDIO_VERSION` - The library version used.
##   * `RTAUDIO_VERSION_MAJOR` - The library version major number.
##   * `RTAUDIO_VERSION_MINOR` - The library version minor number.
##   * `RTAUDIO_VERSION_PATCH` - The library version patch number.
## - Targets:
##   * `rt::Audio` - Target used to link against de library.

find_path(RTAUDIO_INCLUDE_DIR NAMES RtAudio.h)

find_library(RTAUDIO_LIBRARY NAMES rtaudio_static)
find_library(RTAUDIO_LIBRARY_DEBUG NAMES rtaudio_static_d)

set(RTAUDIO_VERSION 4.1.2)
set(RTAUDIO_VERSION_MAJOR 4)
set(RTAUDIO_VERSION_MINOR 1)
set(RTAUDIO_VERSION_PATCH 2)

# handle the QUIETLY and REQUIRED arguments and set RTAUDIO_FOUND to TRUE if
# all listed variables are TRUE
include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(
  LibRtAudio
  REQUIRED_VARS
    RTAUDIO_INCLUDE_DIR
    RTAUDIO_LIBRARY
    RTAUDIO_LIBRARY_DEBUG
  VERSION_VAR RTAUDIO_VERSION_STRING
)

mark_as_advanced(
  RTAUDIO_INCLUDE_DIR
  RTAUDIO_LIBRARY
  RTAUDIO_LIBRARY_DEBUG
)

# export a target
if(NOT TARGET rt::Audio)
  add_library(rt::Audio UNKNOWN IMPORTED)
  set_target_properties(
    rt::Audio
    PROPERTIES
      IMPORTED_LOCATION "${RTAUDIO_LIBRARY}"
      IMPORTED_LOCATION_DEBUG "${RTAUDIO_LIBRARY_DEBUG}"
      INTERFACE_COMPILE_DEFINITIONS "__RTAUDIO_DEBUG__;__WINDOWS_DS__;__WINDOWS_WASAPI__;__WINDOWS_ASIO__"
      INTERFACE_INCLUDE_DIRECTORIES "${RTAUDIO_INCLUDE_DIR}"
      INTERFACE_LINK_LIBRARIES "dsound;ksuser;ole32;uuid;winmm"
  )
endif()
