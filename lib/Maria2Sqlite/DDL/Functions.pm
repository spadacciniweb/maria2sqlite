package Maria2Sqlite::DDL::Functions;

use strict;
use warnings;

use Exporter qw(import);
our @EXPORT = qw( convert_functions );

sub convert_functions {
    $_ = shift;

    $_ =~ s/(group_concat\(.+?) separator( .+?)/$1,$2/gi;

    return $_;
}

1;
