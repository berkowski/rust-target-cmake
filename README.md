# Enable 'Embedded GDB' debugging in CLion for Rust targets

Current CLion builds require CMake targets to use the recent 'Embedded GDB' debug option.
This cmake module provides a simple wrapper around Cargo to create CMake targets for
rust executables, which enables the use of the embedded GDB debugger in CLion.

Hopefully this work around will be rendered obsolete soon by CLion's continuing improvement.

## Usage

- Add the `RustTarget.cmake` file somewhere in you crate.  Project-specific modules are traditionally
  added to a `cmake` subdirectory in project root.
- Create a CMakeLists.txt in your project
- Include the `RustTarget.cmake` module in you CMakeLists.txt
- Add rust targets with the imported `add_rust_target` function


## Example
```cmake
# In your 'CMakeLists.txt', assuming you've placed 'RustTarget.cmake' in a top-level 'cmake' subdir
list(INSERT CMAKE_MODULE_PATH 0 ${CMAKE_CURRENT_SOURCE_DIR}/cmake}
include(RustTarget)
add_rust_target(pwm EXAMPLE FEATURES stm32l0x1 rt)
add_rust_target(firmware RELEASE FEATURES stm32l0x1 rt)
```

## Arguments

`add_rust_target` has one required argument: `name`.  This is the name of the generated CMake target and
by default is also the name of the generated binary.

## Options

- `EXAMPLE`:     The target is an example, not the main binary application
- `RELEASE`:     Compile with the release profile (cargo build --release)
- `NIGHTLY`:     Compile with the nightly release channel
- `BETA`:        Compile with the beta release channel
- `PACKAGE`:     Target is part of a subpackage (if you're using workspaces)
- `PACKAGE_DIR`: Directory of the subpackage if different than the name provided to PACKAGE
- `DEPENDS`:     Additional dependencies of this rust target that should be rebuilt when modified.
- `FEATURES`:    Features to enable
- `TARGET`:      Specifiy a target-triple for compiling (usually set in your .cargo/config)
- `RUST_MODULE_ROOT`:  Root of the rust crate if differnt from PROJECT_SOURCE_DIR

## Example Use
See https://github.com/berkowski/stm32l0xx-hal for a fork of the stm32l0xx-hal crate used with this CMake module

## Acknowledgements

Adapted from:
- https://intellij-support.jetbrains.com/hc/en-us/community/posts/360006477880-Rust-Embedded-gdbserver-JLink
- https://github.com/elmot/f3-rust/blob/master/CMakeLists.txt#L43-L65

Upstream CLion ticket:
- https://youtrack.jetbrains.com/issue/CPP-18738

