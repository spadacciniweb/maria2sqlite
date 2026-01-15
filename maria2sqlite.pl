#!/usr/bin/env perl
use strict;
use warnings;
use Getopt::Long;

my $debug;
my $verbose;
my $synchronous = 'OFF';
my $journal_mode = 'MEMORY';
GetOptions ("debug"        => \$debug,
            "verbose"      => \$verbose,
            "synchronous"  => \$synchronous,
            "journal_mode" => \$journal_mode,
           )
    or die("Error in command line arguments\n");

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

exit 0;

sub init_ddl {
    printf "PRAGMA synchronous = %s;\n", $synchronous;
    printf "PRAGMA journal_mode = %s;\n", $journal_mode;
    print "BEGIN TRANSACTION;\n";
}

sub end_ddl {
    print "END TRANSACTION;";
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

sub delete_line {
    $_ = shift;

    if (/^SET / or
        /^\/\*M?!\d{6}\\- enable the sandbox mode \*\//
    ) {
        return '';
    }

    return $_;
}

sub change_DDL {
    $_ = shift;

    # (un-)signed)
    $_  =~ s/( (un)?signed)//gi;
    $_  =~ s/\bAUTO_INCREMENT\b/AUTOINCREMENT/i;
    $_  =~ s/\(\)//g;

    # INTEGER
    $_  =~ s/\bbit\(\d+\)/integer/gi;
    $_  =~ s/\bbigint\(\d+\)/integer/gi;
    $_  =~ s/\bbool\b/integer/gi;
    $_  =~ s/\bboolean\b/integer/gi;
    $_  =~ s/\bint\(\d+\)/integer/gi;
    $_  =~ s/\bint\d/integer/gi;
    $_  =~ s/\binteger\(\d\)/integer/gi;
    $_  =~ s/\bmediumint\(\d+\)/integer/gi;
    $_  =~ s/\bmiddleint\(\d+\)/integer/gi;
    $_  =~ s/\bserial/integer NOT NULL AUTO_INCREMENT/gi; #TODO manca UNIQUE
    $_  =~ s/\bsmallint\(\d+\)/integer/gi;
    $_  =~ s/\btinyint\(\d+\)/integer/gi;

    # NUMERIC / REAL
    $_ =~ s/\bdec\(\d+,\d+\)/numeric/gi;
    $_ =~ s/\bdecimal\b/numeric/gi;
    $_ =~ s/\bdecimal\(\d+\)/numeric/gi;
    $_ =~ s/\bdecimal\(\d+,\d+\)/numeric/gi;
    $_ =~ s/\bfixed\(\d+,\d+\)/numeric/gi;
    $_ =~ s/\bnumeric\b/numeric/gi;
    $_ =~ s/\bnumeric\(\d+\)/numeric/gi;
    $_ =~ s/\bnumeric\(\d+,\d+\)/numeric/gi;

    # REAL / FLOATING POINT
    $_ =~ s/\bfloat\b/real/gi;
    $_ =~ s/\bfloat\(\d+\)/real/gi;
    $_ =~ s/\bfloat\(\d+,\d+\)/real/gi;
    $_ =~ s/\bdouble\(\d+\)/real/gi;
    $_ =~ s/\bdouble\(\d+,\d+\)/real/gi;
    $_ =~ s/\bdouble(\s+precision)?/real/gi;
    $_ =~ s/\breal\b/real/gi;

    # DATE / TIME / DATETIME / TIMESTAMP
    $_ =~ s/\bdate\b/text/gi;
    $_ =~ s/\bdatetime\b/text/gi;
    $_ =~ s/\bdatetime\(\d+\)/text/gi;
    $_ =~ s/\btimestamp\(\d+\)/text/gi;
    $_ =~ s/\btimestamp\b/text/gi;
    $_ =~ s/\btime\b/text/gi;
    $_ =~ s/\byear\(\d+\)/integer/gi;

    # TEXT TYPES
    $_ =~ s/\bchar\b/text/gi;
    $_ =~ s/\bchar\(\d+\)/text/gi;
    $_ =~ s/\benum\([^)]+\)/text/gi;
    $_ =~ s/\bjson/text/gi;
    $_ =~ s/\blongtext\b/text/gi;
    $_ =~ s/\bmediumtext\b/text/gi;
    $_ =~ s/\bnchar\(\d+\)/text/gi;
    $_ =~ s/\bnvarchar\(\d+\)/text/gi;
    $_ =~ s/\bset\([^)]+\)/text/gi;
    $_ =~ s/\btext\b/text/gi;
    $_ =~ s/\btinytext/text/gi;
    $_ =~ s/\bvarchar\(\d+\)/text/gi;
    $_ =~ s/\bvarchar\b/text/gi;

    # BLOB TYPES
    $_ =~ s/\bbinary\(\d+\)/blob/gi;
    $_ =~ s/\bblob\b/blob/gi;
    $_ =~ s/\blongblob/blob/gi;
    $_ =~ s/\bmediumblob/blob/gi;
    $_ =~ s/\btinyblob/blob/gi;
    $_ =~ s/\bvarbinary\(\d+\)/blob/gi;

    # escape sequence
    $_  =~ s/\\'/''/g;
    $_  =~ s/\\"/"/g;

    # functions
    $_  =~ s/ ?ON UPDATE \w+\(?\)?//gi;

    # PRIMARY KEY / UNIQUE / KEY
    if ($_  =~ /PRIMARY KEY \(`(\w+)`\)/) {
        my $field = $1;
        $_  =~ s/, +PRIMARY KEY \(`\w+`\)//;
        $_  =~ s/(`$field` \w+ NOT NULL)/$1 PRIMARY KEY/;
    }
    if ($_  =~ /UNIQUE KEY `\w+` \(`(\w+)`\)/) {
        my $field = $1;
        $_  =~ s/, +UNIQUE KEY `\w+` \(`\w+`\)//;
        $_  =~ s/(`$field` \w+ NOT NULL)/$1 UNIQUE/;
    }
    $_  =~ s/, +KEY `\w+` \(`\w+`\)//gi;

    # DDL fin
    $_  =~ s/Engine=(\w+) ?//gi;
    $_  =~ s/AUTO_INCREMENT=(\d+) ?//gi;
    $_  =~ s/DEFAULT (CHARSET=\w+)? ?(COLLATE=\w+) ?//gi;
    $_  =~ s/ ?;/;/;

    # CREATE VIEW
    #if ($_  =~ /CREATE ALGORITHM=\w+ .+ VIEW/) {
    $_  =~ s/CREATE ALGORITHM=\w+ .+ VIEW /CREATE VIEW /gi;
    #}

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
