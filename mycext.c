#pragma once
#include "duckdb.h"
#include "stdio.h"

#define DUCKDB_EXTENSION_NAME mycext

#define DUCKDB_EXTENSION_API_VERSION_MAJOR 0
#define DUCKDB_EXTENSION_API_VERSION_MINOR 0
#define DUCKDB_EXTENSION_API_VERSION_PATCH 1

/* forward declarations */
void mycext_init_c_api(duckdb_connection connection, duckdb_extension_info info, struct duckdb_extension_access *access);
void integeradd(duckdb_function_info info, duckdb_data_chunk input, duckdb_vector output);

void integeradd(duckdb_function_info info, duckdb_data_chunk input, duckdb_vector output) {
    idx_t input_size = duckdb_data_chunk_get_size(input);

    duckdb_vector a = duckdb_data_chunk_get_vector(input, 0);
    duckdb_vector b = duckdb_data_chunk_get_vector(input, 1);

    int *a_data = (int*)duckdb_vector_get_data(a);
    int *b_data = (int*)duckdb_vector_get_data(b);
    int *output_data = (int*)duckdb_vector_get_data(output);

    for (idx_t row = 0; row < input_size; row++) {
        output_data[row] = a_data[row] + b_data[row];
    }
};

#define FUNC_NAME "myaddfunc"
void mycext_init_c_api(duckdb_connection connection, duckdb_extension_info info, struct duckdb_extension_access *access) {
    printf("adding %s\n", FUNC_NAME);
    duckdb_scalar_function function = duckdb_create_scalar_function();
    duckdb_scalar_function_set_name(function, FUNC_NAME);

    duckdb_logical_type intType = duckdb_create_logical_type(DUCKDB_TYPE_INTEGER);
    duckdb_scalar_function_add_parameter(function, intType);
    duckdb_scalar_function_add_parameter(function, intType);
    duckdb_scalar_function_set_return_type(function, intType);

    duckdb_scalar_function_set_function(function, integeradd);

    duckdb_register_scalar_function(connection, function);

    duckdb_destroy_logical_type(&intType);
    duckdb_destroy_scalar_function(&function);
}

