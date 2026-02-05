use strict;
use warnings;

use Test::More;
use FindBin;
use lib "$FindBin::Bin/../lib";
use Maria2Sqlite::DDL::Convert;

# fields to integer
is(
    transform_DDL('AUTO_INCREMENT'),
    'AUTOINCREMENT',
    'AUTO_INCREMENT to AUTOINCREMENT'
);

is(
    transform_DDL('`id` bit(4)'),
    '`id` integer',
    'bit to integer'
);

is(
    transform_DDL('`id` bigint(15)'),
    '`id` integer',
    'bigint to integer'
);

is(
    transform_DDL('`id` bool'),
    '`id` integer',
    'bool to integer'
);

is(
    transform_DDL('`id` boolean'),
    '`id` integer',
    'boolean to integer'
);

is(
    transform_DDL('`id` int(10)'),
    '`id` integer',
    'int(10) to integer'
);

is(
    transform_DDL('`id` int2'),
    '`id` integer',
    'int2 to integer'
);

is(
    transform_DDL('`id` int,'),
    '`id` integer,',
    'int to integer'
);

is(
    transform_DDL('`id` int(7),'),
    '`id` integer,',
    'int(n) to integer'
);

is(
    transform_DDL('`id` integer,'),
    '`id` integer,',
    'integer to integer'
);

is(
    transform_DDL('`id` integer(4)'),
    '`id` integer',
    'integer(n) to integer'
);

is(
    transform_DDL('`id` mediumint'),
    '`id` integer',
    'mediumint to integer'
);

is(
    transform_DDL('`id` mediumint(8)'),
    '`id` integer',
    'mediumint(n) to integer'
);

is(
    transform_DDL('`id` middleint'),
    '`id` integer',
    'middleint to integer'
);

is(
    transform_DDL('`id` middleint(8)'),
    '`id` integer',
    'middleint(n) to integer'
);

is(
    transform_DDL('`id` serial'),
    '`id` integer NOT NULL AUTO_INCREMENT',
    'serial to integer NOT NULL AUTO_INCREMENT'
);

is(
    transform_DDL('`id` smallint'),
    '`id` integer',
    'smallint to integer'
);

is(
    transform_DDL('`id` smallint(5)'),
    '`id` integer',
    'smallint(n) to integer'
);

is(
    transform_DDL('`id` tinyint'),
    '`id` integer',
    'tinyint to integer'
);

is(
    transform_DDL('`id` tinyint(1)'),
    '`id` integer',
    'tinyint(n) to integer'
);

# fields to numeric
is(
    transform_DDL('`id` dec,'),
    '`id` numeric,',
    'dec to numeric'
);

is(
    transform_DDL('`id` dec(6,2)'),
    '`id` numeric',
    'dec(n,m) to numeric'
);

is(
    transform_DDL('`id` decimal,'),
    '`id` numeric,',
    'decimal to numeric'
);

is(
    transform_DDL('`id` decimal(6,2)'),
    '`id` numeric',
    'decimal(n,m) to numeric'
);

is(
    transform_DDL('`id` fixed,'),
    '`id` numeric,',
    'fixed to numeric'
);

is(
    transform_DDL('`id` fixed(6,2)'),
    '`id` numeric',
    'fixed(n,m) to numeric'
);

is(
    transform_DDL('`id` numeric,'),
    '`id` numeric,',
    'numeric to numeric'
);

is(
    transform_DDL('`id` numeric(6,2)'),
    '`id` numeric',
    'numeric(n,m) to numeric'
);

# fields to real
is(
    transform_DDL('`id` float,'),
    '`id` real,',
    'float to real'
);

is(
    transform_DDL('`id` float(6,2)'),
    '`id` real',
    'float(n,m) to real'
);

is(
    transform_DDL('`id` double,'),
    '`id` real,',
    'double to real'
);

is(
    transform_DDL('`id` double(6,2)'),
    '`id` real',
    'double(n,m) to real'
);

is(
    transform_DDL('`id` double precision,'),
    '`id` real,',
    'double precision to real'
);

is(
    transform_DDL('`id` double precision(6,2)'),
    '`id` real',
    'double precision(n,m) to real'
);

is(
    transform_DDL('`id` real,'),
    '`id` real,',
    'real to real'
);

is(
    transform_DDL('`id` real(6,2)'),
    '`id` real',
    'real(n,m) to real'
);

# date/time/datetmie/timestamp fields to
is(
    transform_DDL('`d` date,'),
    '`d` text,',
    'date to text'
);

is(
    transform_DDL('`dt` datetime,'),
    '`dt` text,',
    'datetime to text'
);

is(
    transform_DDL('`dt` datetime(6)'),
    '`dt` text',
    'datetime with microseconds to text'
);

is(
    transform_DDL('`t` time,'),
    '`t` text,',
    'time to text'
);

is(
    transform_DDL('`t` time(6)'),
    '`t` text',
    'time with microseconds to text'
);

is(
    transform_DDL('`ts` timestamp,'),
    '`ts` text,',
    'timestamp to text'
);

is(
    transform_DDL('`t` timestamp(6)'),
    '`t` text',
    'timestamp with microseconds to text'
);

is(
    transform_DDL('`y` year,'),
    '`y` integer,',
    'year to integer'
);

is(
    transform_DDL('`y` year(2)'),
    '`y` integer',
    'year (by 2 digits) to integer'
);

# char/enum/json/text fields to text
is(
    transform_DDL('`t` char,'),
    '`t` text,',
    'char to text'
);

is(
    transform_DDL('`t` char(3)'),
    '`t` text',
    'char(n) to text'
);

is(
    transform_DDL('`t` character,'),
    '`t` text,',
    'character to text'
);

is(
    transform_DDL('`t` char(3)'),
    '`t` text',
    'char(n) to text'
);

is(
    transform_DDL('`t` char varying(32)'),
    '`t` text',
    'char varying(n) to text'
);

is(
    transform_DDL('`t` clob'),
    '`t` text',
    'clob to text'
);

is(
    transform_DDL("`t` enum('apple','orange','pear')"),
    '`t` text',
    'enum(...) to text'
);

is(
    transform_DDL("`ipv4` inet4"),
    '`ipv4` text',
    'inet4 to text'
);

is(
    transform_DDL("`ipv6` inet6"),
    '`ipv6` text',
    'inet6 to text'
);

is(
    transform_DDL("`j` json"),
    '`j` text',
    'json to text'
);

is(
    transform_DDL("`t` long,"),
    '`t` text,',
    'long to text'
);

is(
    transform_DDL("`t` long char varying,"),
    '`t` text,',
    'long char varying to text'
);

is(
    transform_DDL("`t` long character varying,"),
    '`t` text,',
    'long character varying to text'
);

is(
    transform_DDL("`t` long varchar,"),
    '`t` text,',
    'long varchar to text'
);

is(
    transform_DDL("`t` long varcharacter,"),
    '`t` text,',
    'long varcharacter to text'
);


is(
    transform_DDL("`t` longtext"),
    '`t` text',
    'longtext to text'
);

is(
    transform_DDL("`t` mediumtext"),
    '`t` text',
    'mediumtext to text'
);

is(
    transform_DDL("`t` nchar,"),
    '`t` text,',
    'nchar to text'
);

is(
    transform_DDL("`t` nchar(5),"),
    '`t` text,',
    'nchar(n) to text'
);

is(
    transform_DDL("`t` nchar varchar(4),"),
    '`t` text,',
    'nchar varchar(n) to text'
);

is(
    transform_DDL("`t` nchar varcharacter(4),"),
    '`t` text,',
    'nchar varcharacter(n) to text'
);

is(
    transform_DDL("`t` nchar varying(4),"),
    '`t` text,',
    'nchar varyng(n) to text'
);

is(
    transform_DDL("`t` nvarchar(6),"),
    '`t` text,',
    'nvarchar to text'
);

is(
    transform_DDL("`t` set('Foo', 'Bar'),"),
    '`t` text,',
    'set(...) to text'
);

is(
    transform_DDL("`t` text,"),
    '`t` text,',
    'text to text'
);

is(
    transform_DDL("`t` text(100),"),
    '`t` text,',
    'text(n) to text'
);

is(
    transform_DDL("`t` tinytext,"),
    '`t` text,',
    'tinytext to text'
);

is(
    transform_DDL("`t` UUID,"),
    '`t` text,',
    'uuid to text'
);

is(
    transform_DDL("`t` varchar(5),"),
    '`t` text,',
    'varchar(n) to text'
);

is(
    transform_DDL("`t` varchar2(5),"),
    '`t` text,',
    'varchar2(n) to text'
);

is(
    transform_DDL("`t` varcharacter(5),"),
    '`t` text,',
    'varcharacter(n) to text'
);

is(
    transform_DDL("`t` national char,"),
    '`t` text,',
    'national char to text'
);

is(
    transform_DDL("`t` national char(5),"),
    '`t` text,',
    'national char(n) to text'
);

is(
    transform_DDL("`t` national varchar(5),"),
    '`t` text,',
    'national varchar to text'
);

is(
    transform_DDL("`t` national varcharacter(5),"),
    '`t` text,',
    'national varcharacter to text'
);

# binary/blob/...
is(
    transform_DDL("`b` binary(4)"),
    '`b` blob',
    'binary to blob'
);

is(
    transform_DDL("`b` binary(4)"),
    '`b` blob',
    'binary to blob'
);

is(
    transform_DDL("`b` blob,"),
    '`b` blob,',
    'blob to blob'
);

is(
    transform_DDL("`b` blob(4)"),
    '`b` blob',
    'blob(n) to blob'
);

is(
    transform_DDL("`b` char byte"),
    '`b` blob',
    'char byte to blob'
);

is(
    transform_DDL("`b` longblob,"),
    '`b` blob,',
    'longblob to blob'
);

is(
    transform_DDL("`b` long varbinary,"),
    '`b` blob,',
    'long varbinary to blob'
);

is(
    transform_DDL("`b` mediumblob,"),
    '`b` blob,',
    'mediumblob to blob'
);

is(
    transform_DDL("`b` raw(32),"),
    '`b` blob,',
    'raw(n) to blob'
);

is(
    transform_DDL("`b` tinyblob,"),
    '`b` blob,',
    'tinyblob to blob'
);

is(
    transform_DDL("`b` varbinary(10),"),
    '`b` blob,',
    'varbinary(n) to blob'
);

# (un)signed
is(
    transform_DDL('`id` int signed'),
    '`id` integer',
    'signed deleted'
);

is(
    transform_DDL('`id` smallint(5) unsigned'),
   '`id` integer',
    'unsigned deleted'
);

# miscellanea
is(
    transform_DDL('`id` int(10) unsigned NOT NULL AUTO_INCREMENT'),
    '`id` integer NOT NULL AUTOINCREMENT',
    'complex numeric field'
);

is(
    transform_DDL("`t` TINYTEXT CHARACTER SET 'utf8mb4' COLLATE 'utf8mb4_danish_ci'"),
    '`t` text',
    'complex text field'
);

done_testing();
