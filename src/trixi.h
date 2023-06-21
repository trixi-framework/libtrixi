#ifndef TRIXI_H_
#define TRIXI_H_

void trixi_initialize(const char * project_directory);
int trixi_setup_simulation(const char * elixir);
double trixi_calculate_dt(int handle);
int trixi_is_finished(int handle);
void trixi_step(int handle);
void trixi_finalize(int handle);

void julia_eval_string(const char * code);

#endif // ifndef LIBTRIXI_H_
