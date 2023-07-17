#ifndef TRIXI_H_
#define TRIXI_H_

/**
 * @addtogroup api_c C API
 * @{
*/

void trixi_initialize(const char * project_directory, const char * depot_path);
int trixi_initialize_simulation(const char * libelixir);
double trixi_calculate_dt(int handle);
int trixi_is_finished(int handle);
void trixi_step(int handle);
void trixi_finalize_simulation(int handle);
void trixi_finalize();

int trixi_version_major();
int trixi_version_minor();
int trixi_version_patch();
const char* trixi_version();

void julia_eval_string(const char * code);

/**
 * @}
 */

#endif // ifndef LIBTRIXI_H_
