use strict;
use warnings;

use Test::More;
use FindBin;
use lib "$FindBin::Bin/../lib";
use Maria2Sqlite::DDL::Convert qw(
    change_keys
    change_others
    change_specific
    change_types
);

# fields to integer
is(
    change_types('AUTO_INCREMENT'),
    'AUTOINCREMENT',
    'AUTO_INCREMENT to AUTOINCREMENT'
);

is(
    change_types('`id` bit(4)'),
    '`id` integer',
    'bit to integer'
);

is(
    change_types('`id` bigint(15)'),
    '`id` integer',
    'bigint to integer'
);

is(
    change_types('`id` bool'),
    '`id` integer',
    'bool to integer'
);

is(
    change_types('`id` boolean'),
    '`id` integer',
    'boolean to integer'
);

is(
    change_types('`id` int(10)'),
    '`id` integer',
    'int(10) to integer'
);

is(
    change_types('`id` int2'),
    '`id` integer',
    'int2 to integer'
);

is(
    change_types('`id` int,'),
    '`id` integer,',
    'int to integer'
);

is(
    change_types('`id` int(7),'),
    '`id` integer,',
    'int(n) to integer'
);

is(
    change_types('`id` integer,'),
    '`id` integer,',
    'integer to integer'
);

is(
    change_types('`id` integer(4)'),
    '`id` integer',
    'integer(n) to integer'
);

is(
    change_types('`id` mediumint'),
    '`id` integer',
    'mediumint to integer'
);

is(
    change_types('`id` mediumint(8)'),
    '`id` integer',
    'mediumint(n) to integer'
);

is(
    change_types('`id` middleint'),
    '`id` integer',
    'middleint to integer'
);

is(
    change_types('`id` middleint(8)'),
    '`id` integer',
    'middleint(n) to integer'
);

is(
    change_types('`id` serial'),
    '`id` integer NOT NULL AUTO_INCREMENT',
    'serial to integer NOT NULL AUTO_INCREMENT'
);

is(
    change_types('`id` smallint'),
    '`id` integer',
    'smallint to integer'
);

is(
    change_types('`id` smallint(5)'),
    '`id` integer',
    'smallint(n) to integer'
);

is(
    change_types('`id` tinyint'),
    '`id` integer',
    'tinyint to integer'
);

is(
    change_types('`id` tinyint(1)'),
    '`id` integer',
    'tinyint(n) to integer'
);

# fields to numeric
is(
    change_types('`id` dec,'),
    '`id` numeric,',
    'dec to numeric'
);

is(
    change_types('`id` dec(6,2)'),
    '`id` numeric',
    'dec(n,m) to numeric'
);

is(
    change_types('`id` decimal,'),
    '`id` numeric,',
    'decimal to numeric'
);

is(
    change_types('`id` decimal(6,2)'),
    '`id` numeric',
    'decimal(n,m) to numeric'
);

is(
    change_types('`id` fixed,'),
    '`id` numeric,',
    'fixed to numeric'
);

is(
    change_types('`id` fixed(6,2)'),
    '`id` numeric',
    'fixed(n,m) to numeric'
);

is(
    change_types('`id` numeric,'),
    '`id` numeric,',
    'numeric to numeric'
);

is(
    change_types('`id` numeric(6,2)'),
    '`id` numeric',
    'numeric(n,m) to numeric'
);

# fields to real
is(
    change_types('`id` float,'),
    '`id` real,',
    'float to real'
);

is(
    change_types('`id` float(6,2)'),
    '`id` real',
    'float(n,m) to real'
);

is(
    change_types('`id` double,'),
    '`id` real,',
    'double to real'
);

is(
    change_types('`id` double(6,2)'),
    '`id` real',
    'double(n,m) to real'
);

is(
    change_types('`id` double precision,'),
    '`id` real,',
    'double precision to real'
);

is(
    change_types('`id` double precision(6,2)'),
    '`id` real',
    'double precision(n,m) to real'
);

is(
    change_types('`id` real,'),
    '`id` real,',
    'real to real'
);

is(
    change_types('`id` real(6,2)'),
    '`id` real',
    'real(n,m) to real'
);

# date/time/datetmie/timestamp fields to
is(
    change_types('`d` date,'),
    '`d` text,',
    'date to text'
);

is(
    change_types('`dt` datetime,'),
    '`dt` text,',
    'datetime to text'
);

is(
    change_types('`dt` datetime(6)'),
    '`dt` text',
    'datetime with microseconds to text'
);

is(
    change_types('`t` time,'),
    '`t` text,',
    'time to text'
);

is(
    change_types('`t` time(6)'),
    '`t` text',
    'time with microseconds to text'
);

is(
    change_types('`ts` timestamp,'),
    '`ts` text,',
    'timestamp to text'
);

is(
    change_types('`t` timestamp(6)'),
    '`t` text',
    'timestamp with microseconds to text'
);

is(
    change_types('`y` year,'),
    '`y` integer,',
    'year to integer'
);

is(
    change_types('`y` year(2)'),
    '`y` integer',
    'year (by 2 digits) to integer'
);

# char/enum/json/text fields to text
is(
    change_types('`t` char,'),
    '`t` text,',
    'char to text'
);

is(
    change_types('`t` char(3)'),
    '`t` text',
    'char(n) to text'
);

is(
    change_types('`t` character,'),
    '`t` text,',
    'character to text'
);

is(
    change_types('`t` char(3)'),
    '`t` text',
    'char(n) to text'
);

is(
    change_types('`t` char varying(32)'),
    '`t` text',
    'char varying(n) to text'
);

is(
    change_types('`t` clob'),
    '`t` text',
    'clob to text'
);

is(
    change_types("`t` enum('apple','orange','pear')"),
    '`t` text',
    'enum(...) to text'
);

is(
    change_types("`ipv4` inet4"),
    '`ipv4` text',
    'inet4 to text'
);

is(
    change_types("`ipv6` inet6"),
    '`ipv6` text',
    'inet6 to text'
);

is(
    change_types("`j` json"),
    '`j` text',
    'json to text'
);

is(
    change_types("`t` long,"),
    '`t` text,',
    'long to text'
);

is(
    change_types("`t` long char varying,"),
    '`t` text,',
    'long char varying to text'
);

is(
    change_types("`t` long character varying,"),
    '`t` text,',
    'long character varying to text'
);

is(
    change_types("`t` long varchar,"),
    '`t` text,',
    'long varchar to text'
);

is(
    change_types("`t` long varcharacter,"),
    '`t` text,',
    'long varcharacter to text'
);


is(
    change_types("`t` longtext"),
    '`t` text',
    'longtext to text'
);

is(
    change_types("`t` mediumtext"),
    '`t` text',
    'mediumtext to text'
);

is(
    change_types("`t` nchar,"),
    '`t` text,',
    'nchar to text'
);

is(
    change_types("`t` nchar(5),"),
    '`t` text,',
    'nchar(n) to text'
);

is(
    change_types("`t` nchar varchar(4),"),
    '`t` text,',
    'nchar varchar(n) to text'
);

is(
    change_types("`t` nchar varcharacter(4),"),
    '`t` text,',
    'nchar varcharacter(n) to text'
);

is(
    change_types("`t` nchar varying(4),"),
    '`t` text,',
    'nchar varyng(n) to text'
);

is(
    change_types("`t` nvarchar(6),"),
    '`t` text,',
    'nvarchar to text'
);

is(
    change_types("`t` set('Foo', 'Bar'),"),
    '`t` text,',
    'set(...) to text'
);

is(
    change_types("`t` text,"),
    '`t` text,',
    'text to text'
);

is(
    change_types("`t` text(100),"),
    '`t` text,',
    'text(n) to text'
);

is(
    change_types("`t` tinytext,"),
    '`t` text,',
    'tinytext to text'
);

is(
    change_types("`t` UUID,"),
    '`t` text,',
    'uuid to text'
);

is(
    change_types("`t` varchar(5),"),
    '`t` text,',
    'varchar(n) to text'
);

is(
    change_types("`t` varchar2(5),"),
    '`t` text,',
    'varchar2(n) to text'
);

is(
    change_types("`t` varcharacter(5),"),
    '`t` text,',
    'varcharacter(n) to text'
);

is(
    change_types("`t` national char,"),
    '`t` text,',
    'national char to text'
);

is(
    change_types("`t` national char(5),"),
    '`t` text,',
    'national char(n) to text'
);

is(
    change_types("`t` national varchar(5),"),
    '`t` text,',
    'national varchar to text'
);

is(
    change_types("`t` national varcharacter(5),"),
    '`t` text,',
    'national varcharacter to text'
);

# binary/blob/...
is(
    change_types("`b` binary(4)"),
    '`b` blob',
    'binary to blob'
);

is(
    change_types("`b` binary(4)"),
    '`b` blob',
    'binary to blob'
);

is(
    change_types("`b` blob,"),
    '`b` blob,',
    'blob to blob'
);

is(
    change_types("`b` blob(4)"),
    '`b` blob',
    'blob(n) to blob'
);

is(
    change_types("`b` char byte"),
    '`b` blob',
    'char byte to blob'
);

is(
    change_types("`b` longblob,"),
    '`b` blob,',
    'longblob to blob'
);

is(
    change_types("`b` long varbinary,"),
    '`b` blob,',
    'long varbinary to blob'
);

is(
    change_types("`b` mediumblob,"),
    '`b` blob,',
    'mediumblob to blob'
);

is(
    change_types("`b` raw(32),"),
    '`b` blob,',
    'raw(n) to blob'
);

is(
    change_types("`b` tinyblob,"),
    '`b` blob,',
    'tinyblob to blob'
);

is(
    change_types("`b` varbinary(10),"),
    '`b` blob,',
    'varbinary(n) to blob'
);

# (un)signed
is(
    change_types('`id` int signed'),
    '`id` integer',
    'signed deleted'
);

is(
    change_types('`id` smallint(5) unsigned'),
   '`id` integer',
    'unsigned deleted'
);

done_testing();
