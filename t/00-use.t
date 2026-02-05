use strict;
use warnings;

use Test::More;
use FindBin;
use lib "$FindBin::Bin/../lib";

use_ok('Maria2Sqlite::Beautifier');
use_ok('Maria2Sqlite::Session');
use_ok('Maria2Sqlite::Test');
use_ok('Maria2Sqlite::Stats');
use_ok('Maria2Sqlite::Unwrap');
use_ok('Maria2Sqlite::DDL::Convert');
use_ok('Maria2Sqlite::DDL::Functions');
use_ok('Maria2Sqlite::DDL::Unsupported');

done_testing();
