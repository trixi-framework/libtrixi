#ifndef TRIXI_H_
#define TRIXI_H_

#include <t8.h>
#include <t8_forest/t8_forest_general.h>

void trixi_initialize(const char * project_directory);
int trixi_initialize_simulation(const char * libelixir);
double trixi_calculate_dt(int handle);
int trixi_is_finished(int handle);
void trixi_step(int handle);
void trixi_finalize_simulation(int handle);
void trixi_finalize();

t8_forest_t trixi_get_t8code_mesh(int handle);

void julia_eval_string(const char * code);

#endif // ifndef LIBTRIXI_H_
