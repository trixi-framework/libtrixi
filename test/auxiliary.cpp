#include <gtest/gtest.h>

extern "C" {
    int show_debug_output();
    void update_depot_path(const char * project_directory, const char * depot_path);
}

// Julia project path defined via cmake
const char * julia_project_path = JULIA_PROJECT_PATH;

const char* default_depot_path = "julia-depot";


TEST(AuxiliaryTest, DebugOutput) {

    const char * envvar = "LIBTRIXI_DEBUG";

    // environment variable not set -> no debug output
    unsetenv(envvar);
    EXPECT_EQ( show_debug_output(), 0 );

    // environment variable set to "all" -> debug output
    setenv(envvar, "all", /*overwrite*/ 1 );
    EXPECT_EQ( show_debug_output(), 1 );

    // environment variable set to "c" -> debug output
    setenv(envvar, "c", /*overwrite*/ 1 );
    EXPECT_EQ( show_debug_output(), 1 );

    // environment variable set to "julia" -> no debug output
    setenv(envvar, "julia", /*overwrite*/ 1 );
    EXPECT_EQ( show_debug_output(), 0 );
}


TEST(AuxiliaryTest, DepotPath) {

    const char * depot_envvar = "JULIA_DEPOT_PATH";

    // unset depot path environment variable
    unsetenv(depot_envvar);

    // let it be set explicitly and check
    update_depot_path( julia_project_path, julia_project_path );
    EXPECT_STREQ( getenv(depot_envvar), julia_project_path );

    // unset depot path environment variable
    unsetenv(depot_envvar);

    // let it be set to default location and check
    update_depot_path( julia_project_path, NULL );
    std::string expected_depot_path( julia_project_path );
    expected_depot_path.append("/");
    expected_depot_path.append( default_depot_path );
    EXPECT_STREQ( getenv(depot_envvar), expected_depot_path.c_str() );

    // unset depot path environment variable
    unsetenv(depot_envvar);

    // be evil: use probably non-existing project path
    const char * garbage_path = "/no/where";
    EXPECT_DEATH( update_depot_path( garbage_path, NULL ),
                  "could not resolve depot path");

    // unset depot path environment variable
    unsetenv(depot_envvar);

    // be evil: use too long project path
    const char * garbage = "this_string_is_just_way_toooooooooooooooooooo_long"
                           "this_string_is_just_way_toooooooooooooooooooo_long"
                           "this_string_is_just_way_toooooooooooooooooooo_long"
                           "this_string_is_just_way_toooooooooooooooooooo_long"
                           "this_string_is_just_way_toooooooooooooooooooo_long"
                           "this_string_is_just_way_toooooooooooooooooooo_long"
                           "this_string_is_just_way_toooooooooooooooooooo_long"
                           "this_string_is_just_way_toooooooooooooooooooo_long"
                           "this_string_is_just_way_toooooooooooooooooooo_long"
                           "this_string_is_just_way_toooooooooooooooooooo_long"
                           "this_string_is_just_way_toooooooooooooooooooo_long"
                           "this_string_is_just_way_toooooooooooooooooooo_long"
                           "this_string_is_just_way_toooooooooooooooooooo_long"
                           "this_string_is_just_way_toooooooooooooooooooo_long"
                           "this_string_is_just_way_toooooooooooooooooooo_long"
                           "this_string_is_just_way_toooooooooooooooooooo_long"
                           "this_string_is_just_way_toooooooooooooooooooo_long"
                           "this_string_is_just_way_toooooooooooooooooooo_long"
                           "this_string_is_just_way_toooooooooooooooooooo_long"
                           "this_string_is_just_way_toooooooooooooooooooo_long"
                           "this_string_is_just_way_toooooooooooooooooooo_long";
    EXPECT_DEATH( update_depot_path( garbage, NULL ),
                  "buffer size not sufficient for depot path construction");
}
