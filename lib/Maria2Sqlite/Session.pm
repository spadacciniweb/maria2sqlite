package Maria2Sqlite::Session;

use strict;
use warnings;

use Exporter qw(import);
our @EXPORT = qw( init_session
                  end_session
                );

sub init_session {
    my $synchronous = shift;
    my $journal_mode = shift;

    printf "PRAGMA synchronous = %s;\n", $synchronous;
    printf "PRAGMA journal_mode = %s;\n", $journal_mode;
    print "BEGIN TRANSACTION;\n";
}

sub end_session {
    print "END TRANSACTION;\n";
}

1;
