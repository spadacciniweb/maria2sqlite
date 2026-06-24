use strict;
use warnings;

use Test::More;
use FindBin;
use lib "$FindBin::Bin/../lib";
use Maria2Sqlite::Beautifier;

is(
    is_comment(
        '--'
    ),
    1,
    'comment'
);

is(
    is_comment(
        '-- Table structure for'
    ),
    1,
    'comment'
);

is(
    is_comment(
        '-- MariaDB'
    ),
    1,
    'comment'
);

done_testing();
