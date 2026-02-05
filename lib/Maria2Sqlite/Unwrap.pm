package Maria2Sqlite::Unwrap;

use strict;
use warnings;

use Exporter qw(import);
our @EXPORT = qw( unwrap_line
                  unwrap_row
                );

sub unwrap_row {
    $_ = shift;

    if (/^\/\*!\d{5} (.+) ?\*\/(;)?$/) {
        return $1 . ($2 || '');
    }

    return $_;
}

sub unwrap_line {
    $_ = shift;

    if (/^\/\*!\d{5} (.+) ?\*\/;$/) {
        return $1 . ';';
    }

    return $_;
}

1;
