#include "trixi.h"

/**
 * @anchor trixi_version_major_api_c
 *
 * @brief Return major version number of libtrixi.
 *
 * This function may be run before `trixi_initialize` has been called.
 *
 * @return Major version of libtrixi.
 */
int trixi_version_major() {

    // Get function pointer
    int (*version_major)() = trixi_function_pointers[TRIXI_FTPR_VERSION_MAJOR];

    // Call function
    return version_major();
}

/**
 * @anchor trixi_version_minor_api_c
 *
 * @brief Return minor version number of libtrixi.
 *
 * This function may be run before `trixi_initialize` has been called.
 *
 * @return Minor version of libtrixi.
 */
int trixi_version_minor() {

    // Get function pointer
    int (*version_minor)() = trixi_function_pointers[TRIXI_FTPR_VERSION_MINOR];

    // Call function
    return version_minor();
}

/**
 * @anchor trixi_version_patch_api_c
 *
 * @brief Return patch version number of libtrixi.
 *
 * This function may be run before `trixi_initialize` has been called.
 *
 * @return Patch version of libtrixi.
 */
int trixi_version_patch() {

    // Get function pointer
    int (*version_patch)() = trixi_function_pointers[TRIXI_FTPR_VERSION_PATCH];

    // Call function
    return version_patch();
}

/**
 * @anchor trixi_version_api_c
 *
 * @brief Return full version string of libtrixi.
 *
 * The return value is a read-only pointer to a NULL-terminated string with the version
 * information. This may include not just MAJOR.MINOR.PATCH but possibly also additional
 * build or development version information.
 *
 * The returned pointer is to static memory and must not be used to change the contents of
 * the version string. Multiple calls to the function will return the same address.
 *
 * This function is thread-safe and may be run before `trixi_initialize` has been called.
 *
 * @return Pointer to a read-only, NULL-terminated character array with the full version of
 *         libtrixi.
 */
const char* trixi_version() {

    // Get function pointer
    const char* (*version)() = trixi_function_pointers[TRIXI_FTPR_VERSION];

    // Call function
    return version();
}