#!/usr/bin/env perl

use strict;
use warnings;

use Getopt::Long;
use FindBin;
use lib "$FindBin::Bin/lib";
use Maria2Sqlite::Beautifier;
use Maria2Sqlite::Session;
use Maria2Sqlite::Test;
use Maria2Sqlite::Stats;
use Maria2Sqlite::Unwrap;
use Maria2Sqlite::DDL::Convert;
use Maria2Sqlite::DDL::Functions;
use Maria2Sqlite::DDL::Unsupported;

my $debug;
my $verbose;
my $help;
my $synchronous = 'OFF';
my $journal_mode = 'MEMORY';
my $stats_enabled;
my $strict; my $warn;
GetOptions ("debug"          => \$debug,
            "verbose"        => \$verbose,
            "help"           => \$help,
            "synchronous=s"  => \$synchronous,
            "journal_mode=s" => \$journal_mode,
            "stats"          => \$stats_enabled,
            "strict"         => \$strict,
            "warn"           => \$warn,
           ) or usage();

if ($help) {
    print usage();
    exit 0;
}

sub usage {
    return <<"USAGE";
Usage: maria2sqlite.pl [options]

Options:
  --debug                 Enable debug output (use for development purposes only).
  --verbose               Enable verbose output (use for development purposes only).
  --synchronous <value>   Set synchronous mode (default: OFF)
  --journal_mode <value>  Set journal mode (default: MEMORY)
  --stats                 Prints a summary of dropped or converted constructs to STDERR
  --strict                Aborts the conversion on unsupported constructs instead of
                          silently dropping them
  --warn                  Emit warning to STDERR on unsupported constructs instead of
                          silently dropping them
  --help, -h              Show this help message

USAGE
}

my $stats = $stats_enabled
    ? { dropped   => undef,
        rewritten => undef,
      }
    : undef;

init_session($synchronous, $journal_mode);
my $line;
foreach my $row (<STDIN>) {
    chomp $row;
    my $unwrap_row = unwrap_row($row);
    print "-R.$unwrap_row.\n"
        if $debug and $verbose and
           $row ne $unwrap_row;

    # concat rows in DDL line
    $line = ($line || '') . $unwrap_row;

    if (is_whole_line($line)) {
        print "-O.$line.\n"
            if $debug;
        ($line, $stats) = unsupported($line, $stats, $strict, $warn);
        my $unwrap_line = unwrap_line($line);
        print "-U.$unwrap_line.\n"
            if $debug and ($verbose or $unwrap_line ne $line);
        my ($clean_line, $stats) = delete_line($unwrap_line, $stats);
        print "-C.$clean_line.\n"
            if $debug and ($verbose or $clean_line ne $unwrap_line);
        my $ddl_line;
        ($ddl_line, $stats) = transform_DDL($clean_line, $stats);
        $ddl_line = improve_readability($ddl_line);
        $ddl_line = convert_functions($ddl_line);
        if ($ddl_line) {
            if ($debug and ($verbose or $ddl_line ne $clean_line)) {
                print "-F.$ddl_line.\n"
            } else {
                print "$ddl_line\n";
            }
        }
        
        $line = '';
    }
}
end_session();

print_stats($stats)
    if $stats_enabled;

exit 0;
