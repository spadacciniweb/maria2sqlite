package Maria2Sqlite::Beautifier;

use strict;
use warnings;

use Exporter qw(import);
our @EXPORT = qw( delete_line
                  improve_readability
                );

sub delete_line {
    $_ = shift;
    my $stats = shift;

    if (/^SET /) {
        $stats->{dropped}->{set}++;
        return '';
    }
    if (/^\/\*M?!\d{6}\\- enable the sandbox mode \*\//) {
        $stats->{dropped}->{sandbox}++;
        return '';
    }

    return ($_, $stats);
}

sub improve_readability {
    $_ = shift;

    $_  =~ s/\( /(\n  /;
    $_  =~ s/, /,\n  /g;
    $_  =~ s/(\w)\);/$1\n);/;
    $_  =~ s/\)\);/)\n);/;

    return $_;
}

1;
