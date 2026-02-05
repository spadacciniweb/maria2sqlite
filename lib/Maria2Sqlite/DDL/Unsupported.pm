package Maria2Sqlite::DDL::Unsupported;

use strict;
use warnings;

use Exporter qw(import);
our @EXPORT = qw( unsupported );

sub unsupported {
    $_ = shift;
    my $stats = shift;
    my $strict = shift;
    my $warn = shift;

    if ($_  =~ /\b(UN)?LOCK\s+TABLES.*;/i) {
        $stats->{dropped}->{lock}++
           unless $1;
        if ($strict) {
            print "Lock are not supported (line $.)\n";
            exit 2;
        } elsif ($warn) {
            warn "Lock are not supported (line $.).\n";
        }
        $_ = '';
    }

    if ($_  =~ /\b(CREATE|DROP)\s+TRIGGER.*;/i) {
        $stats->{dropped}->{trigger}++
            if $1 eq 'CREATE';
        if ($strict) {
            print "Triggers are not supported (line $.).\n\n";
            exit 2;
        } elsif ($warn) {
            warn "Triggers are not supported (line $.).\n"
        }
        $_ = '';
    }

    return ($_, $stats);
}

1;
