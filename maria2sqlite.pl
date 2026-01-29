#!/usr/bin/env perl
use strict;
use warnings;
use Getopt::Long;

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

my %stats = (
    dropped => { charset   => 0,
                 collation => 0,
                 engine    => 0,
                 lock      => 0,
                 others    => 0,
                 trigger   => 0,
                 set       => 0,
                 sandbox   => 0,
               },
    rewritten => { primary_key => 0,
                   unique_key  => 0,
                 }
);

init_ddl();
my $line;
foreach my $row (<STDIN>) {
    chomp $row;
    my $unwrap_row = unwrap_row($row);
    print "-R.$unwrap_row.\n"
        if $debug and $verbose and
           $row ne $unwrap_row;

    # concat rows in DDL line
    $line = ($line || '') . $unwrap_row;

    if (is_whole_line($row)) {
        print "-O.$line.\n"
            if $debug;
        $line = strict_mode($line);
        my $unwrap_line = unwrap_line($line);
        print "-U.$unwrap_line.\n"
            if $debug and ($verbose or $unwrap_line ne $line);
        my $clean_line = delete_line($unwrap_line);
        print "-C.$clean_line.\n"
            if $debug and ($verbose or $clean_line ne $unwrap_line);
        my $ddl_line = change_DDL($clean_line);
        $ddl_line = better_readability($ddl_line);
        $ddl_line = change_function($ddl_line);
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
end_ddl();

if ($stats_enabled) {
    say STDERR "\n# maria2sqlite statistics";
    say STDERR "-"x30;

    for my $action (sort keys %stats) {
        for my $type (sort keys %{$stats{$action}}) {
            printf STDERR "%9s.%-11s %4s\n", $action, $type, $stats{$action}{$type};
        }
    }
    say STDERR "-"x30;
}

exit 0;

sub init_ddl {
    printf "PRAGMA synchronous = %s;\n", $synchronous;
    printf "PRAGMA journal_mode = %s;\n", $journal_mode;
    print "BEGIN TRANSACTION;\n";
}

sub end_ddl {
    print "END TRANSACTION;\n";
}

sub is_whole_line {
    $_ = shift;
    return 1 if $_ =~ /;$/ or $_ =~ / \*\/ $/;
    return 0;
}

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

sub strict_mode {
    $_ = shift;

    if ($_  =~ /\b(UN)?LOCK\s+TABLES.*;/i) {
        $stats{dropped}{lock}++
            if $1;
        if ($strict) {
            say "Lock are not supported (line $.)";
            exit 2;
        } elsif ($warn) {
            warn "Lock are not supported (line $.).\n";
        }
        return '';
    }

    if ($_  =~ /\b(CREATE|DROP)\s+TRIGGER.*;/i) {
        $stats{dropped}{trigger}++
            if $1 eq 'CREATE';
        if ($strict) {
            say "Triggers are not supported (line $.).";
            exit 2;
        } elsif ($warn) {
            warn "Triggers are not supported (line $.).\n"
        }
        return '';
    }

    return $_;
}

sub delete_line {
    $_ = shift;

    if (/^SET /) {
        $stats{dropped}{set}++;
        return '';
    }
    if (/^\/\*M?!\d{6}\\- enable the sandbox mode \*\//) {
        $stats{dropped}{sandbox}++;
        return '';
    }

    return $_;
}

sub change_DDL {
    $_ = shift;

    # (un-)signed)
    $_  =~ s/\s+(?:un)?signed\b//gi;
    $_  =~ s/\bAUTO_INCREMENT\b/AUTOINCREMENT/i;
    $_  =~ s/\(\s*\)//g;

    # INTEGER
    $_  =~ s/\bbit\s*\(\d+\)/integer/gi;
    $_  =~ s/\bbigint\s*\(\d+\)/integer/gi;
    $_  =~ s/\bbool\b/integer/gi;
    $_  =~ s/\bboolean\s*\b/integer/gi;
    $_  =~ s/\bint\s*\(\d+\)/integer/gi;
    $_  =~ s/\bint\d\b/integer/gi;
    $_  =~ s/\binteger\s*\(\d\)/integer/gi;
    $_  =~ s/\bmediumint\s*\(\d+\)/integer/gi;
    $_  =~ s/\bmiddleint\s*\(\d+\)/integer/gi;
    $_  =~ s/\bserial\b/integer NOT NULL AUTO_INCREMENT/gi;
    $_  =~ s/\bsmallint\s*\(\d+\)/integer/gi;
    $_  =~ s/\btinyint\s*\(\d+\)/integer/gi;

    # NUMERIC / REAL
    $_ =~ s/\bdec\s*\(\d+,\d+\)/numeric/gi;
    $_ =~ s/\bdecimal\b/numeric/gi;
    $_ =~ s/\bdecimal\s*\(\d+(,\d+)?\)/numeric/gi;
    $_ =~ s/\bfixed\s*\(\d+,\d+\)/numeric/gi;
    $_ =~ s/\bnumeric\b/numeric/gi;
    $_ =~ s/\bnumeric\s*\(\d+(,\d+)?\)/numeric/gi;

    # REAL / FLOATING POINT
    $_ =~ s/\bfloat\b/real/gi;
    $_ =~ s/\bfloat\s*\(\d+(,\d+)?\)/real/gi;
    $_ =~ s/\bdouble\s*\(\d+(,\d+)?\)/real/gi;
    $_ =~ s/\bdouble\s*(\s+precision)?/real/gi;
    $_ =~ s/\breal\b/real/gi;

    # DATE / TIME / DATETIME / TIMESTAMP
    $_ =~ s/\bdate\b/text/gi;
    $_ =~ s/\bdatetime\b/text/gi;
    $_ =~ s/\bdatetime\s*\(\d+\)/text/gi;
    $_ =~ s/\btime\b/text/gi;
    $_ =~ s/\btimestamp\s*\(\d+\)/text/gi;
    $_ =~ s/\btimestamp\b/text/gi;
    $_ =~ s/\byear\s*\(\d+\)/integer/gi;

    # TEXT TYPES
    $_ =~ s/\bchar\b/text/gi;
    $_ =~ s/\bchar\s*\(\d+\)/text/gi;
    $_ =~ s/\benum\s*\([^)]+\)/text/gi;
    $_ =~ s/\bjson\b/text/gi;
    $_ =~ s/\blongtext\b/text/gi;
    $_ =~ s/\bmediumtext\b/text/gi;
    $_ =~ s/\bnchar\s*\(\d+\)/text/gi;
    $_ =~ s/\bnvarchar\s*\(\d+\)/text/gi;
    $_ =~ s/\bset\s*\([^)]+\)/text/gi;
    $_ =~ s/\btext\b/text/gi;
    $_ =~ s/\btinytext\b/text/gi;
    $_ =~ s/\bvarchar\(\d+\)/text/gi;
    $_ =~ s/\bvarchar\b/text/gi;

    # BLOB TYPES
    $_ =~ s/\bbinary\s*\(\d+\)/blob/gi;
    $_ =~ s/\bblob\b/blob/gi;
    $_ =~ s/\blongblob\b/blob/gi;
    $_ =~ s/\bmediumblob\b/blob/gi;
    $_ =~ s/\btinyblob\b/blob/gi;
    $_ =~ s/\bvarbinary\s*\(\d+\)/blob/gi;

    # escape sequence
    $_  =~ s/\\'/''/g;
    $_  =~ s/\\"/"/g;

    # functions
    #$_  =~ s/ ?ON UPDATE\s*\S//gi;
    $_  =~ s/ ?ON UPDATE \w+\(?\)?//gi;

    # PRIMARY KEY / UNIQUE / KEY / FOREIGN KEY
    if ($_  =~ /,\s+PRIMARY KEY \(`(\w+)`\)/) {
        $stats{rewritten}{primary_key}++;
        my $field = $1;
        $_  =~ s/,\s+PRIMARY KEY \(`\w+`\)//;
        $_  =~ s/(`$field`\s+\w+\s+NOT NULL\b)/$1 PRIMARY KEY/i;
    }
    if ($_  =~ /,\s+UNIQUE KEY\s+`\w+`\s+\(`(\w+)`\)/) {
        $stats{rewritten}{unique_key}++;
        my $field = $1;
        $_  =~ s/, +UNIQUE KEY\s+`\w+`\s+\(`\w+`\)//;
        $_  =~ s/(`$field`\s+\w+\s+NOT NULL)/$1 UNIQUE/;
    }
    $_  =~ s/,\s+KEY\s+`\w+`\s+\(`\w+`\)//gi;
    $_  =~ s/\bCONSTRAINT\s+`\w+`\s+FOREIGN KEY\s+\(`(\w+)`\)\s+REFERENCES\s+`(\w+)`\s+\(`(\w+)`\)/FOREIGN KEY($1) REFERENCES $2($3)/gi;

    # DDL Engine
    if ($_  =~ /\bENGINE=/i) {
        $stats{dropped}{engine}++;
        $_  =~ s/Engine=(\w+)\s*//i;
    }
    $_  =~ s/AUTO_INCREMENT=(\d+) ?//gi;
    if ($_ =~ /DEFAULT\s+CHARSET=/) {
        $stats{dropped}{charset}++;
    }
    if ($_ =~ /\bCOLLATE=/) {
        $stats{dropped}{collation}++;
    }
    $_  =~ s/DEFAULT (CHARSET=\w+)? ?(COLLATE=\w+) ?//i;
    $_  =~ s/ ?;/;/;

    # CREATE VIEW
    $_  =~ s/CREATE ALGORITHM=\w+ .+ VIEW /CREATE VIEW /i;

    return $_;
}

sub better_readability {
    $_ = shift;

    $_  =~ s/\( /(\n  /;
    $_  =~ s/, /,\n  /g;
    $_  =~ s/(\w)\);/$1\n);/;
    $_  =~ s/\)\);/)\n);/;

    return $_;
}

sub change_function {
    $_ = shift;

    $_ =~ s/(group_concat\(.+?) separator( .+?)/$1,$2/gi;

    return $_;
}
