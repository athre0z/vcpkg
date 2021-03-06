include(vcpkg_common_functions)

if("wdk" IN_LIST FEATURES)
    if(NOT VCPKG_TARGET_IS_WINDOWS)
        message(FATAL_ERROR "Windows Driver Kit support is only available builds targeting Windows")
    endif()
    set(WITH_WDK ON)
else()
    set(WITH_WDK OFF)
endif()

# OpenCL C headers
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO KhronosGroup/OpenCL-Headers
    REF 0d5f18c6e7196863bc1557a693f1509adfcee056
    SHA512 7e8fa6c8e73c660d8e9e31ddea3bfef887ed827fc21a1da559bde9dd4af6c52a91f609401bb718528b5c96d21e4c01aee7b8027bdf3dec4b0aa326270788a4b0
    HEAD_REF master
)

file(INSTALL
        "${SOURCE_PATH}/CL"
    DESTINATION
        ${CURRENT_PACKAGES_DIR}/include
)

# OpenCL C++ headers
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO KhronosGroup/OpenCL-CLHPP
    REF d62a02090625655e5b2d791d6a58618b043c989c
    SHA512 837bbe914931d2f18a468f21634dbd4d088eda0a2f22eea23304c0323b9ee064c3ee76db7ebf28ba67fbe07c44129241f8dca62512d89bc7a6b35c2b4b316ed7
    HEAD_REF master
)

vcpkg_find_acquire_program(PYTHON3)

vcpkg_execute_required_process(
    COMMAND "${PYTHON3}" "${SOURCE_PATH}/gen_cl_hpp.py"
        -i ${SOURCE_PATH}/input_cl.hpp
        -o ${CURRENT_PACKAGES_DIR}/include/CL/cl.hpp
    WORKING_DIRECTORY ${SOURCE_PATH}
    LOGNAME generate_clhpp-${TARGET_TRIPLET}
)

vcpkg_execute_required_process(
    COMMAND "${PYTHON3}" "${SOURCE_PATH}/gen_cl_hpp.py"
        -i ${SOURCE_PATH}/input_cl2.hpp
        -o ${CURRENT_PACKAGES_DIR}/include/CL/cl2.hpp
    WORKING_DIRECTORY ${SOURCE_PATH}
    LOGNAME generate_cl2hpp-${TARGET_TRIPLET}
)
message(STATUS "Generating OpenCL C++ headers done")

# OpenCL ICD loader
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO KhronosGroup/OpenCL-ICD-Loader
    REF e6e30ab9c7a61c171cf68d2e7f5c0ce28e2a4eae
    SHA512 f3563c0a4c094d3795d8386ec0db41189d350ab8136d80ae5de611ee3db87fbb0ab851bad2b33e111eddf135add5dbfef77d96979473ca5a23c036608d443378
    HEAD_REF master
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DOPENCL_ICD_LOADER_HEADERS_DIR=${CURRENT_PACKAGES_DIR}/include
        -DOPENCL_ICD_LOADER_REQUIRE_WDK=${WITH_WDK} 
)

vcpkg_build_cmake(TARGET OpenCL)

if(VCPKG_TARGET_IS_WINDOWS)
  file(INSTALL
          "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/OpenCL.lib"
      DESTINATION
          ${CURRENT_PACKAGES_DIR}/lib
  )
  
  file(INSTALL
          "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/OpenCL.lib"
      DESTINATION
          ${CURRENT_PACKAGES_DIR}/debug/lib
  )
endif(VCPKG_TARGET_IS_WINDOWS)
if(VCPKG_TARGET_IS_LINUX)
  file(INSTALL
          "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/libOpenCL.a"
      DESTINATION
          ${CURRENT_PACKAGES_DIR}/lib
  )
  
  file(INSTALL
          "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/libOpenCL.a"
      DESTINATION
          ${CURRENT_PACKAGES_DIR}/debug/lib
  )
endif(VCPKG_TARGET_IS_LINUX)

file(INSTALL
        "${SOURCE_PATH}/LICENSE"
    DESTINATION
        ${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright
)
file(COPY
        ${CMAKE_CURRENT_LIST_DIR}/usage
    DESTINATION
        ${CURRENT_PACKAGES_DIR}/share/${PORT}
)

file(COPY
        ${CMAKE_CURRENT_LIST_DIR}/vcpkg-cmake-wrapper.cmake
    DESTINATION
        ${CURRENT_PACKAGES_DIR}/share/${PORT}
)
