package Maria2Sqlite::Test;

use strict;
use warnings;

use Exporter qw(import);
our @EXPORT = qw( is_whole_line );

sub is_whole_line {
    $_ = shift;

    return 1 if $_ =~ /;$/ or $_ =~ / \*\/ $/;
    return 0;
}

1;
