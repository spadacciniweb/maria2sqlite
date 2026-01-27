#!/usr/bin/env perl
use strict;
use warnings;
use Getopt::Long;

my $debug;
my $verbose;
my $synchronous = 'OFF';
my $foreign_keys;
my $journal_mode = 'MEMORY';
GetOptions ("debug"        => \$debug,
            "verbose"      => \$verbose,
            "synchronous"  => \$synchronous,
            "foreign_keys" => \$foreign_keys,
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
    printf "PRAGMA foreign_keys = OFF;\n";
    print "BEGIN TRANSACTION;\n";
}

sub end_ddl {
    print "END TRANSACTION;\n";
    printf "PRAGMA foreign_keys = ON;"
        if $foreign_keys;
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

    # PRIMARY KEY / UNIQUE / KEY
    if ($_  =~ /\bPRIMARY KEY \(`(\w+)`\)/) {
        my $field = $1;
        $_  =~ s/, +PRIMARY KEY \(`\w+`\)//;
        $_  =~ s/(`$field`\s+\w+\s+NOT NULL\b)/$1 PRIMARY KEY/i;
    }
    if ($_  =~ /UNIQUE KEY\s+`\w+`\s+\(`(\w+)`\)/) {
        my $field = $1;
        $_  =~ s/, +UNIQUE KEY\s+`\w+`\s+\(`\w+`\)//;
        $_  =~ s/(`$field`\s+\w+\s+NOT NULL)/$1 UNIQUE/;
    }
    $_  =~ s/, +KEY\s+`\w+`\s+\(`\w+`\)//gi;

    # DDL Engine
    $_  =~ s/Engine=(\w+) ?//gi;
    $_  =~ s/AUTO_INCREMENT=(\d+) ?//gi;
    $_  =~ s/DEFAULT (CHARSET=\w+)? ?(COLLATE=\w+) ?//gi;
    $_  =~ s/ ?;/;/;

    # CREATE VIEW
    $_  =~ s/CREATE ALGORITHM=\w+ .+ VIEW /CREATE VIEW /gi;

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
