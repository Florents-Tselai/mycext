SET allow_extensions_metadata_mismatch=true;

load './mycext.duckdb_extension';
select myaddfunc(1,2);
