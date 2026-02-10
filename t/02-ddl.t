use strict;
use warnings;

use Test::More;
use FindBin;
use lib "$FindBin::Bin/../lib";
use Maria2Sqlite::DDL::Convert;

is(
    transform_DDL(
        'CREATE TABLE `t` ( `id` int(10) unsigned NOT NULL AUTO_INCREMENT);'
    ),
    'CREATE TABLE `t` ( `id` integer NOT NULL AUTOINCREMENT);',
    'simple DDL'
);

is(
    transform_DDL(
        "CREATE TABLE `tbl` (`t` TINYTEXT CHARACTER SET 'utf8mb4' COLLATE 'utf8mb4_danish_ci');"
    ),
    "CREATE TABLE `tbl` (`t` text);",
    'semicomplex DDL'
);

is(
    transform_DDL(
        "CREATE TABLE `tbl` ( `id` smallint(5) unsigned NOT NULL AUTO_INCREMENT, `description` varchar(50) DEFAULT NULL, PRIMARY KEY (`id`) ) ENGINE=InnoDB AUTO_INCREMENT=18 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;"
    ),
    "CREATE TABLE `tbl` ( `id` integer NOT NULL PRIMARY KEY AUTOINCREMENT, `description` text DEFAULT NULL );",
    'complex DDL'
);

done_testing();
