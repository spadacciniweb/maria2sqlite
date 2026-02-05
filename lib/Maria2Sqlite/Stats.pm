package Maria2Sqlite::Stats;

use strict;
use warnings;

use Exporter qw(import);
our @EXPORT = qw( print_stats );

sub print_stats {
    my $stats = shift;

    print STDERR "\n# maria2sqlite statistics\n";
    print STDERR "-"x35, "\n";

    for my $action (sort keys %$stats) {
        for my $type (sort keys %{$stats->{$action}}) {
            printf STDERR "%9s.%-15s %5s\n", $action, $type, $stats->{$action}->{$type};
        }
    }
    print STDERR "-"x35, "\n";

    return 0;
}

1;
