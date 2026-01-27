# maria2sqlite

`maria2sqlite` is a small Unix-style command-line filter written in **Perl** that converts a **MariaDB/MySQL SQL dump** into a **SQLite-compatible SQL script**.

It reads SQL from standard input and writes the converted output to standard output, making it suitable for pipelines and large dumps without intermediate files.

Repository:  
https://github.com/spadacciniweb/maria2sqlite

## Synopsis

```sh
cat dump_mysql.sql | ./maria2sqlite.pl > dump_sqlite.sql
-- or --
mysqldump -u USER -p DATABASE | ./maria2sqlite.pl > dump_sqlite.sql
```

and to create sqlite db:

```sh
sqlite3 mysqlite.db < dump_sqlite.sql
```

## Description

`maria2sqlite` reads a MariaDB/MySQL SQL dump from standard input and rewrites it into a form accepted by SQLite.

The conversion is performed as a streaming transformation: input is processed line by line and written to standard output. This design allows the tool to operate on large dumps and to be easily integrated into Unix pipelines.

The tool does not require access to a running MySQL or MariaDB server and operates solely on SQL text.

## Features

- Stream-based SQL conversion (stdin → stdout)
- Suitable for large dumps
- No temporary or intermediate files
- Designed for use with `mysqldump`
- Converts:
  - table definitions
  - data inserts
  - indexes (where compatible)
  - views
- Minimal runtime dependencies

## Options

The following command-line options are supported:

```text
--debug
    enable debug output

--verbose
    enable verbose output

--synchronous=MODE
    set SQLite PRAGMA synchronous
    default: OFF

--journal_mode=MODE
    set SQLite PRAGMA journal_mode.
    default: MEMORY

--stats
    prints a summary of dropped or converted constructs to STDERR

--strict
    aborts the conversion on unsupported constructs instead of silently dropping them

--help, -h
    show help message
```

## Examples

Convert an existing MariaDB/MySQL dump file:

```sh
cat dump_mysql.sql | ./maria2sqlite.pl > dump_sqlite.sql
```

Convert directly from mysqldump without intermediate files:

```sh
mysqldump -u USER -p DATABASE | ./maria2sqlite.pl > dump_sqlite.sql
```

Change SQLite pragmas:

```sh
mysqldump mydb | ./maria2sqlite.pl --synchronous=NORMAL --journal_mode=WAL > dump_sqlite.sql

```

Enable debug and verbose (only for developer):

```sh
mysqldump mydb | ./maria2sqlite.pl --debug --verbose | less
```

Import the resulting SQL into SQLite:

```sh
sqlite3 mysqlite.db < dump_sqlite.sql
```

## Views

If the input SQL dump contains `VIEW` definitions, they are rewritten and emitted as SQLite-compatible views whenever possible.

MySQL/MariaDB-specific clauses are removed or adapted to conform to SQLite syntax.

Views depending on complex queries or vendor-specific SQL extensions may require manual review and adjustment.

## Limitations

- Stored procedures, functions, triggers, and events are not supported
- Some indexes and constraints may not be preserved exactly
- Highly MySQL/MariaDB-specific SQL constructs may require post-processing

## Use Cases

- Migration of small to medium MariaDB/MySQL databases to SQLite
- Development and testing
- Offline data analysis
- One-off data exports

## License

This program is free software: you can redistribute it and/or modify it under the terms of the  
**GNU General Public License, Version 3**.

See the `LICENSE` file for the full license text.

## Contributing

Bug reports, feature requests, and pull requests are welcome and appreciated.

If you encounter an incompatibility, an edge case, or have an improvement to suggest, feel free to open an issue or submit a contribution.
