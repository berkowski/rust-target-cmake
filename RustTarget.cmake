#! add_rust_target : Adds a rust target to help integrate embedded development with CLion.
#
# The CLion embedded debugger is currently only available for CMake projects.  This function wraps
# cargo build targets in CMake, which then allows use of the embedded gdb debuggin target (with peripheral views)
#
# Adapted from https://github.com/elmot/f3-rust/blob/master/CMakeLists.txt#L43-L65
#
#
# \arg:name Name of the generated target.  Should be the same as the package or example names
# \param: EXAMPLE  Target is an example, not the main binary application
# \param: RELEASE  Compile with the release profile (cargo build --release)
# \param: NIGHTLY Compile with the nightly release channel
# \param: BETA Compile with the beta release channel
# \param: PACKAGE  Target is part of a subpackage (if you're using workspaces)
# \param: PACKAGE_DIR  Directory of the subpackage if different than the name provided to PACKAGE
# \param: DEPENDS Additional dependencies of this rust target that should be rebuilt when modified.
# \param: FEATURES  Features to enable
# \param: TARGET  Specify a target-triple for compiling
# \param: RUST_MODULE_ROOT  Root of the rust crate if differnt from PROJECT_SOURCE_DIR
function(add_rust_target name)
    include(CMakeParseArguments)
    set(options EXAMPLE RELEASE NIGHTLY BETA)
    set(singleValues RUST_MODULE_ROOT PACKAGE TARGET PACKAGE_DIR OUTPUT)
    set(multiValues DEPENDS FEATURES)
    cmake_parse_arguments(PARSE_ARGV 1 TARGET "${options}" "${singleValues}" "${multiValues}")

    if(DEFINED TARGET_RUST_MODULE_ROOT)
        set(RUST_MODULE_ROOT ${TARGET_RUST_MODULE_ROOT})
    else()
        set(RUST_MODULE_ROOT ${PROJECT_SOURCE_DIR})
    endif(DEFINED TARGET_RUST_MODULE_ROOT)
        
    if(DEFINED TARGET_OUTPUT)
        set(OUTPUT_NAME ${TARGET_OUTPUT})
    else()
        set(OUTPUT_NAME ${name})
    endif(DEFINED TARGET_OUTPUT)

    list(APPEND CARGO_COMMAND cargo)

    if(${TARGET_NIGHTLY})
        list(APPEND CARGO_COMMAND +nightly)
    elseif(${TARGET_BETA})
        list(APPEND CARGO_COMMAND +beta)
    endif(${TARGET_NIGHTLY})

    list(APPEND CARGO_COMMAND build)

    if(${TARGET_RELEASE})
        list(APPEND CARGO_COMMAND --release)
        set(BUILD_DIR release)
    else()
        set(BUILD_DIR debug)
    endif(${TARGET_RELEASE})

    set(TARGET_OUTPUT ${RUST_MODULE_ROOT}/target/${RUST_TARGET_ARCH}/${BUILD_DIR}/${OUTPUT_NAME})
    set_source_files_properties(${TARGET_OUTPUT} PROPERTIES EXTERNAL_OBJECT true GENERATED true)

    if(DEFINED TARGET_PACKAGE_DIR)
        set(PACKAGE_ROOT ${RUST_MODULE_ROOT}/${TARGET_PACKAGE_DIR})
    else()
        set(PACKAGE_ROOT ${RUST_MODULE_ROOT})
    endif(DEFINED TARGET_PACKAGE_DIR)

    if(DEFINED TARGET_TARGET)
        list(APPEND CARGO_COMMAND --target ${TARGET_TARGET})
    endif(DEFINED TARGET_TARGET)


    if(DEFINED TARGET_PACKAGE)
        list(APPEND CARGO_COMMAND --package ${TARGET_PACKAGE})
    endif(DEFINED TARGET_PACKAGE)

    if(${TARGET_EXAMPLE})
        list(APPEND CARGO_COMMAND --example ${OUTPUT_NAME})
    endif(${TARGET_EXAMPLE})

    if(DEFINED TARGET_FEATURES)
        list(JOIN TARGET_FEATURES " " TARGET_FEATURES_STR)
        list(APPEND CARGO_COMMAND --features "${TARGET_FEATURES_STR}")
    endif(DEFINED TARGET_FEATURES)

    list(APPEND DEPENDS ${PACKAGE_ROOT}/src/*.* ${PACKAGE_ROOT}/Cargo.*)
    if(DEFINED TARGET_DEPENDS)
        list(APPEND DEPENDS ${TARGET_DEPENDS})
    endif(DEFINED TARGET_DEPENDS)

    list(JOIN CARGO_COMMAND " " CARGO_COMMAND_STR)

    add_custom_command(OUTPUT ${TARGET_OUTPUT}
            COMMAND ${CARGO_COMMAND}
            COMMENT "${CARGO_COMMAND_STR}"
            DEPENDS ${DEPENDS}
            WORKING_DIRECTORY ${RUST_MODULE_ROOT}
            USES_TERMINAL
            )
    add_custom_target(${name} DEPENDS ${TARGET_OUTPUT})

endfunction(add_rust_target)

