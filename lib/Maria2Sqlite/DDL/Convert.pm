package Maria2Sqlite::DDL::Convert;

use strict;
use warnings;

use Exporter qw(import);
our @EXPORT = qw( transform_DDL );
our @EXPORT_OK = qw( change_keys
                     change_others
                     change_specific
                     change_types
                   );

sub transform_DDL {
    $_ = shift;
    my $stats = shift || undef;

    ($_, $stats) = change_keys(
                       change_others(
                           change_types(
                               change_specific($_, $stats)
                           )
                       )
                   );
    return $stats
        ? ($_, $stats)
        : $_;
}

sub change_types {
    $_ = shift;
    my $stats = shift;

    # (un-)signed)
    $_  =~ s/\s+(?:un)?signed\b//gi;
    $_  =~ s/\bAUTO_INCREMENT\b/AUTOINCREMENT/i;
    $_  =~ s/\(\s*\)//g;

    # INTEGER
    $_  =~ s/\bbit\(\d+\)/integer/gi;
    $_  =~ s/\bbigint\(\d+\)/integer/gi;
    $_  =~ s/\bbool\b/integer/gi;
    $_  =~ s/\bboolean\b/integer/gi;
    $_  =~ s/\bint\(\d+\)/integer/gi;
    $_  =~ s/\bint\d\b/integer/gi;
    $_  =~ s/\bint\b/integer/gi;
    $_  =~ s/\binteger\(\d\)/integer/gi;
    $_  =~ s/\binteger\b/integer/gi;
    $_  =~ s/\bmediumint\(\d+\)/integer/gi;
    $_  =~ s/\bmediumint\b/integer/gi;
    $_  =~ s/\bmiddleint\(\d+\)/integer/gi;
    $_  =~ s/\bmiddleint\b/integer/gi;
    $_  =~ s/\bserial\b/integer NOT NULL AUTO_INCREMENT/gi;
    $_  =~ s/\bsmallint\(\d+\)/integer/gi;
    $_  =~ s/\bsmallint\b/integer/gi;
    $_  =~ s/\btinyint\(\d+\)/integer/gi;
    $_  =~ s/\btinyint\b/integer/gi;

    # NUMERIC / REAL
    $_ =~ s/\bdec\s*\(\d+,\d+\)/numeric/gi;
    $_ =~ s/\bdec\b/numeric/gi;
    $_ =~ s/\bdecimal\s*\(\d+(,\d+)?\)/numeric/gi;
    $_ =~ s/\bdecimal\b/numeric/gi;
    $_ =~ s/\bfixed\s*\(\d+,\d+\)/numeric/gi;
    $_ =~ s/\bfixed\b/numeric/gi;

    $_ =~ s/\bnumeric\s*\(\d+(,\d+)?\)/numeric/gi;
    $_ =~ s/\bnumeric\b/numeric/gi;

    # REAL / FLOATING POINT
    $_ =~ s/\bfloat\s*\(\d+(,\d+)?\)/real/gi;
    $_ =~ s/\bfloat\b/real/gi;
    $_ =~ s/\bdouble(\s+precision)?\(\d+(,\d+)?\)/real/gi;
    $_ =~ s/\bdouble(\s+precision)?\b/real/gi;
    $_ =~ s/\breal\s*\(\d+(,\d+)?\)/real/gi;
    $_ =~ s/\breal\b/real/gi;

    # DATE / TIME / DATETIME / TIMESTAMP
    $_ =~ s/\bdate\b/text/gi;
    $_ =~ s/\bdatetime\s*\(\d+\)/text/gi;
    $_ =~ s/\bdatetime\b/text/gi;
    $_ =~ s/\btime\s*\(\d+\)/text/gi;
    $_ =~ s/\btime\b/text/gi;
    $_ =~ s/\btimestamp\s*\(\d+\)/text/gi;
    $_ =~ s/\btimestamp\b/text/gi;
    $_ =~ s/\byear\s*\(\d+\)/integer/gi;
    $_ =~ s/\byear\b/integer/gi;

    # convert some  synonyms
    $_ =~ s/\bn?char varying(\(\d+\))/varchar$1/gi;
    $_ =~ s/\bclob\b/longtext/gi;

    # BLOB TYPES
    $_ =~ s/\bbinary\(\d+\)/blob/gi;
    $_ =~ s/\bblob\(\d+\)/blob/gi;
    $_ =~ s/\bblob\b/blob/gi;
    $_ =~ s/\bchar byte\b/blob/gi;
    $_ =~ s/\blongblob\b/blob/gi;
    $_ =~ s/\blong varbinary\b/blob/gi;
    $_ =~ s/\bmediumblob\b/blob/gi;
    $_ =~ s/\braw\(\d+\)/blob/gi;
    $_ =~ s/\btinyblob\b/blob/gi;
    $_ =~ s/\bvarbinary\(\d+\)/blob/gi;

    # TEXT TYPES
    $_ =~ s/\benum\s*\([^)]+\)/text/gi;
    $_ =~ s/\binet[46]\b/text/gi;
    $_ =~ s/\bjson\b/text/gi;
    $_ =~ s/\blong(?:\s+(?:char varying|character varying|varchar|varcharacter))?\b/text/gi;
    $_ =~ s/\blongtext\b/text/gi;
    $_ =~ s/\bmediumtext\b/text/gi;
    $_ =~ s/\bnational\s+(?:char varying|character varying|varchar|varcharacter)\(\d+\)/text/gi;
    $_ =~ s/\b(?:nchar\s+)?varchar(?:acter)?\(\d+\)/text/gi;
    $_ =~ s/\bset\s*\([^)]+\)/text/gi;
    $_ =~ s/\btext(?:\(\d+\))/text/gi;
    $_ =~ s/\btext\b/text/gi;
    $_ =~ s/\btinytext\b/text/gi;
    $_ =~ s/\buuid\b/text/gi;
    $_ =~ s/\bvarchar2\(\d+\)/text/gi;
    $_ =~ s/\bn?varchar(?:acter)?\(\d+\)/text/gi;
    $_ =~ s/\b(national\s+)?char\(\d+\)/text/gi;
    $_ =~ s/\b(?:national\s+)?char(?:acter)?\b/text/gi;
    $_ =~ s/\bn?char(?:\s+varying)?\(\d+\)/text/gi;
    $_ =~ s/\bnchar\b/text/gi;

    return $stats
        ? ($_, $stats)
        : $_;
}

sub change_others {
    $_ = shift;
    my $stats = shift;

    # escape sequence
    $_  =~ s/\\'/''/g;
    $_  =~ s/\\"/"/g;

    # functions
    #$_  =~ s/ ?ON UPDATE\s*\S//gi;
    $_  =~ s/ ?ON UPDATE \w+\(?\)?//gi;

    return $stats
        ? ($_, $stats)
        : $_;
}

sub change_keys {
    $_ = shift;
    my $stats = shift;

    # PRIMARY KEY / UNIQUE / KEY / FOREIGN KEY
    if ($_  =~ /,\s+PRIMARY KEY \(`(\w+)`\)/) {
        $stats->{rewritten}->{primary_key}++;
        my $field = $1;
        $_  =~ s/,\s+PRIMARY KEY \(`\w+`\)//;
        $_  =~ s/(`$field`\s+\w+\s+NOT NULL\b)/$1 PRIMARY KEY/i;
    } 
    if ($_  =~ /,\s+UNIQUE KEY\s+`\w+`\s+\(`(\w+)`\)/) {
        $stats->{rewritten}->{unique_key}++;
        my $field = $1;
        $_  =~ s/, +UNIQUE KEY\s+`\w+`\s+\(`\w+`\)//;
        $_  =~ s/(`$field`\s+\w+\s+NOT NULL)/$1 UNIQUE/;
    }
    $_  =~ s/,\s+KEY\s+`\w+`\s+\(`\w+`\)//gi;
    $_  =~ s/\bCONSTRAINT\s+`\w+`\s+FOREIGN KEY\s+\(`(\w+)`\)\s+REFERENCES\s+`(\w+)`\s+\(`(\w+)`\)/FOREIGN KEY($1) REFERENCES $2($3)/gi;

    return $stats
        ? ($_, $stats)
        : $_;
}

sub change_specific {
    $_ = shift;
    my $stats = shift;

=head
    if ($_  =~ /\bCHECK\(\)\b/i) {
        $stats->{dropped}->{check}++;
        $_  =~ s/\bCHECK\(\)\b//i;
    }
=cut

    # DDL Engine
    if ($_  =~ /\bENGINE=/i) {
        $stats->{dropped}->{engine}++;
        $_  =~ s/Engine=(\w+)\s*//i;
    }
    $_  =~ s/\s?AUTO_INCREMENT=(?:\d+)//gi;
    if ($stats) {
        $stats->{dropped}->{tbl_charset} += () = $_ =~ /\bCHARACTER\s+SET\s+'\w+'/gi;
        $stats->{dropped}->{tbl_collation} += () = $_ =~ /\bCOLLATE\s'\w+'/;
        $stats->{dropped}->{db_charset}++
            if $_ =~ /DEFAULT\s+CHARSET=/;
        $stats->{dropped}->{db_collation}++
            if $_ =~ /\bCOLLATE=/;
    }
    $_  =~ s/\bDEFAULT\s+CHARSET=\w+(\s+COLLATE=\w+)?\s*//i;
    $_  =~ s/\s+CHARACTER\s+SET\s+'\w+'//gi;
    $_  =~ s/\s+COLLATE\s+'\w+'//gi;
    $_  =~ s/\s*;/;/;

    # CREATE VIEW
    $_  =~ s/CREATE ALGORITHM=\w+ .+ VIEW /CREATE VIEW /i;

    return $stats
        ? ($_, $stats)
        : $_;
}

1;
