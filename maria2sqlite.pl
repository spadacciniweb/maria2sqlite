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
        return $1 . $2 || '';
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
    $_  =~ s/ AUTO_INCREMENT/ AUTOINCREMENT/i;
    $_  =~ s/\(\)//g;

    # INTEGER
    $_  =~ s/ bit\(\d+\)/ integer/gi;
    $_  =~ s/ bigint\(\d+\)/ integer/gi;
    $_  =~ s/ bool/ integer/gi;
    $_  =~ s/ boolean/ integer/gi;
    $_  =~ s/ int\d/ integer/gi;
    $_  =~ s/ integer\(\d\)/ integer/gi;
    $_  =~ s/ mediumint\(\d+\)/ integer/gi;
    $_  =~ s/ middleint\(\d+\)/ integer/gi;
    $_  =~ s/ serial/ integer NOT NULL AUTO_INCREMENT/gi; #TODO manca UNIQUE
    $_  =~ s/ smallint\(\d+\)/ integer/gi;
    $_  =~ s/ tinyint\(\d+\)/ integer/gi;
    $_  =~ s/ int\(\d+\)/ integer/gi;

    # NUMERIC
#    $_  =~ s/numeric(\(\\d+(\,\d+)?))? ( (un)?signed)?/integer/gi;
#DECIMAL(10,5)
#DOUBLE PRECISION[(M,D)]
#BOOLEAN
#DATE
#DATETIME 

    # REAL
# dec
# double precision
# fixed
# float4
# number
# numeric
# real

    # TEXT
#CHARACTER(20)
#VARCHAR(255)
#VARYING CHARACTER(255)
#NCHAR(55)
#NATIVE CHARACTER(70)
#NVARCHAR(100)
#TEXT
#CLOB 

    # BLOB

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
