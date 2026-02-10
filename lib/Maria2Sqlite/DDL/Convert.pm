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
                       change_types(
                           change_specific( $_, $stats )
                       )
                   )
        if /^\s*CREATE\s/i;

    ($_, $stats) = change_others( $_, $stats );

    return $stats
        ? ($_, $stats)
        : $_;
}

sub change_types {
    $_ = shift;
    my $stats = shift;

    my $c;
    # un-)signed / autoincrement
    ($c = s/\s+(?:un)?signed//gi)
        && $stats && ($stats->{rewritten}->{signed} += $c || 0);
    ($c = s/\bAUTO_INCREMENT\b/AUTOINCREMENT/gi)
        && $stats && ($stats->{rewritten}->{autoincrement} += $c || 0);
    ($c = s/\(\s*\)//g)
        && $stats && ($stats->{rewritten}->{function_brackets} += $c || 0);

    # INTEGER
    ($c = s/\bbit\(\d+\)/integer/gi)
        && $stats && ($stats->{rewritten}->{type_integer} += $c || 0);
    ($c = s/\bbigint\(\d+\)/integer/gi)
        && $stats && ($stats->{rewritten}->{type_integer} += $c || 0);
    ($c = s/\bbool\b/integer/gi)
        && $stats && ($stats->{rewritten}->{type_integer} += $c) || 0;
    ($c = s/\bboolean\b/integer/gi)
        && $stats && ($stats->{rewritten}->{type_integer} += $c || 0);
    ($c = s/\bint\(\d+\)/integer/gi)
        && $stats && ($stats->{rewritten}->{type_integer} += $c || 0);
    ($c = s/\bint\d\b/integer/gi)
        && $stats && ($stats->{rewritten}->{type_integer} += $c || 0);
    ($c = s/\bint\b/integer/gi)
        && $stats && ($stats->{rewritten}->{type_integer} += $c || 0);
    ($c = s/\binteger\(\d\)/integer/gi)
        && $stats && ($stats->{rewritten}->{type_integer} += $c || 0);
    ($c = s/\binteger\b/integer/gi)
        && $stats && ($stats->{rewritten}->{type_integer} += $c || 0);
    ($c = s/\bmediumint\(\d+\)/integer/gi)
        && $stats && ($stats->{rewritten}->{type_integer} += $c || 0);
    ($c = s/\bmediumint\b/integer/gi)
        && $stats && ($stats->{rewritten}->{type_integer} += $c || 0);
    ($c = s/\bmiddleint\(\d+\)/integer/gi)
        && $stats && ($stats->{rewritten}->{type_integer} += $c || 0);
    ($c = s/\bmiddleint\b/integer/gi)
        && $stats && ($stats->{rewritten}->{type_integer} += $c || 0);
    ($c = s/\bserial\b/integer NOT NULL AUTO_INCREMENT/gi)
        && $stats && ($stats->{rewritten}->{type_integer} += $c || 0);
    ($c = s/\bsmallint\(\d+\)/integer/gi)
        && $stats && ($stats->{rewritten}->{type_integer} += $c || 0);
    ($c = s/\bsmallint\b/integer/gi)
        && $stats && ($stats->{rewritten}->{type_integer} += $c || 0);
    ($c = s/\btinyint\(\d+\)/integer/gi)
        && $stats && ($stats->{rewritten}->{type_integer} += $c || 0);
    ($c = s/\btinyint\b/integer/gi)
        && $stats && ($stats->{rewritten}->{type_integer} += $c || 0);

    # NUMERIC
    ($c = s/\bdec\s*\(\d+,\d+\)/numeric/gi)
        && $stats && ($stats->{rewritten}->{type_numeric} += $c || 0);
    ($c = s/\bdec\b/numeric/gi)
        && $stats && ($stats->{rewritten}->{type_numeric} += $c || 0);
    ($c = s/\bdecimal\s*\(\d+(,\d+)?\)/numeric/gi)
        && $stats && ($stats->{rewritten}->{type_numeric} += $c || 0);
    ($c = s/\bdecimal\b/numeric/gi)
        && $stats && ($stats->{rewritten}->{type_numeric} += $c || 0);
    ($c = s/\bfixed\s*\(\d+,\d+\)/numeric/gi)
        && $stats && ($stats->{rewritten}->{type_numeric} += $c || 0);
    ($c = s/\bfixed\b/numeric/gi)
        && $stats && ($stats->{rewritten}->{type_numeric} += $c || 0);
    ($c = s/\bnumeric\s*\(\d+(,\d+)?\)/numeric/gi)
        && $stats && ($stats->{rewritten}->{type_numeric} += $c || 0);
    ($c = s/\bnumeric\b/numeric/gi)
        && $stats && ($stats->{rewritten}->{type_numeric} += $c || 0);

    # REAL / FLOATING POINT
    ($c = s/\bfloat\s*\(\d+(,\d+)?\)/real/gi)
        && $stats && ($stats->{rewritten}->{type_real} += $c || 0);
    ($c = s/\bfloat\b/real/gi)
        && $stats && ($stats->{rewritten}->{type_real} += $c || 0);
    ($c = s/\bdouble(\s+precision)?\(\d+(,\d+)?\)/real/gi)
        && $stats && ($stats->{rewritten}->{type_real} += $c || 0);
    ($c = s/\bdouble(\s+precision)?\b/real/gi)
        && $stats && ($stats->{rewritten}->{type_real} += $c || 0);
    ($c = s/\breal\s*\(\d+(,\d+)?\)/real/gi)
        && $stats && ($stats->{rewritten}->{type_real} += $c || 0);
    ($c = s/\breal\b/real/gi)
        && $stats && ($stats->{rewritten}->{type_real} += $c || 0);

    # DATE / TIME / DATETIME / TIMESTAMP
    ($c = s/\bdate\b/text/gi)
        && $stats && ($stats->{rewritten}->{type_datetime} += $c || 0);
    ($c = s/\bdatetime\s*\(\d+\)/text/gi)
        && $stats && ($stats->{rewritten}->{type_datetime} += $c || 0);
    ($c = s/\bdatetime\b/text/gi)
        && $stats && ($stats->{rewritten}->{type_datetime} += $c || 0);
    ($c = s/\btime\s*\(\d+\)/text/gi)
        && $stats && ($stats->{rewritten}->{type_datetime} += $c || 0);
    ($c = s/\btime\b/text/gi)
        && $stats && ($stats->{rewritten}->{type_datetime} += $c || 0);
    ($c = s/\btimestamp\s*\(\d+\)/text/gi)
        && $stats && ($stats->{rewritten}->{type_datetime} += $c || 0);
    ($c = s/\btimestamp\b/text/gi)
        && $stats && ($stats->{rewritten}->{type_datetime} += $c || 0);
    ($c = s/\byear\s*\(\d+\)/integer/gi)
        && $stats && ($stats->{rewritten}->{type_datetime} += $c || 0);
    ($c = s/\byear\b/integer/gi)
        && $stats && ($stats->{rewritten}->{type_datetime} += $c || 0);

    # convert some  synonyms
    ($c = s/\bn?char varying(\(\d+\))/varchar$1/gi)
        && $stats && ($stats->{rewritten}->{synonyms} += $c || 0);
    ($c = s/\bclob\b/longtext/gi)
        && $stats && ($stats->{rewritten}->{synonyms} += $c || 0);

    # BLOB TYPES
    ($c = s/\bbinary\(\d+\)/blob/gi)
        && $stats && ($stats->{rewritten}->{type_blob} += $c || 0);
    ($c = s/\bblob\(\d+\)/blob/gi)
        && $stats && ($stats->{rewritten}->{type_blob} += $c || 0);
    ($c = s/\bblob\b/blob/gi)
        && $stats && ($stats->{rewritten}->{type_blob} += $c || 0);
    ($c = s/\bchar byte\b/blob/gi)
        && $stats && ($stats->{rewritten}->{type_blob} += $c || 0);
    ($c = s/\blongblob\b/blob/gi)
        && $stats && ($stats->{rewritten}->{type_blob} += $c || 0);
    ($c = s/\blong varbinary\b/blob/gi)
        && $stats && ($stats->{rewritten}->{type_blob} += $c || 0);
    ($c = s/\bmediumblob\b/blob/gi)
        && $stats && ($stats->{rewritten}->{type_blob} += $c || 0);
    ($c = s/\braw\(\d+\)/blob/gi)
        && $stats && ($stats->{rewritten}->{type_blob} += $c || 0);
    ($c = s/\btinyblob\b/blob/gi)
        && $stats && ($stats->{rewritten}->{type_blob} += $c || 0);
    ($c = s/\bvarbinary\(\d+\)/blob/gi)
        && $stats && ($stats->{rewritten}->{type_blob} += $c || 0);

    # TEXT TYPES
    ($c = s/\benum\s*\([^)]+\)/text/gi)
        && $stats && ($stats->{rewritten}->{type_text} += $c || 0);
    ($c = s/\binet[46]\b/text/gi)
        && $stats && ($stats->{rewritten}->{type_text} += $c || 0);
    ($c = s/\bjson\b/text/gi)
        && $stats && ($stats->{rewritten}->{type_text} += $c || 0);
    ($c = s/\blong(?:\s+(?:char varying|character varying|varchar|varcharacter))?\b/text/gi)
        && $stats && ($stats->{rewritten}->{type_text} += $c || 0);
    ($c = s/\blongtext\b/text/gi)
        && $stats && ($stats->{rewritten}->{type_text} += $c || 0);
    ($c = s/\bmediumtext\b/text/gi)
        && $stats && ($stats->{rewritten}->{type_text} += $c || 0);
    ($c = s/\bnational\s+(?:char varying|character varying|varchar|varcharacter)\(\d+\)/text/gi)
        && $stats && ($stats->{rewritten}->{type_text} += $c || 0);
    ($c = s/\b(?:nchar\s+)?varchar(?:acter)?\(\d+\)/text/gi)
        && $stats && ($stats->{rewritten}->{type_text} += $c || 0);
    ($c = s/\bset\s*\([^)]+\)/text/gi)
        && $stats && ($stats->{rewritten}->{type_text} += $c || 0);
    ($c = s/\btext(?:\(\d+\))/text/gi)
        && $stats && ($stats->{rewritten}->{type_text} += $c || 0);
    ($c = s/\btext\b/text/gi)
        && $stats && ($stats->{rewritten}->{type_text} += $c || 0);
    ($c = s/\btinytext\b/text/gi)
        && $stats && ($stats->{rewritten}->{type_text} += $c || 0);
    ($c = s/\buuid\b/text/gi)
        && $stats && ($stats->{rewritten}->{type_text} += $c || 0);
    ($c = s/\bvarchar2\(\d+\)/text/gi)
        && $stats && ($stats->{rewritten}->{type_text} += $c || 0);
    ($c = s/\bn?varchar(?:acter)?\(\d+\)/text/gi)
        && $stats && ($stats->{rewritten}->{type_text} += $c || 0);
    ($c = s/\b(national\s+)?char\(\d+\)/text/gi)
        && $stats && ($stats->{rewritten}->{type_text} += $c || 0);
    ($c = s/\b(?:national\s+)?char(?:acter)?\b/text/gi)
        && $stats && ($stats->{rewritten}->{type_text} += $c || 0);
    ($c = s/\bn?char(?:\s+varying)?\(\d+\)/text/gi)
        && $stats && ($stats->{rewritten}->{type_text} += $c || 0);
    ($c = s/\bnchar\b/text/gi)
        && $stats && ($stats->{rewritten}->{type_text} += $c || 0);

    return $stats
        ? ($_, $stats)
        : $_;
}

sub change_others {
    $_ = shift;
    my $stats = shift || undef;

    my $c;
    ($c = s/\\'/''/g)
        && $stats && ($stats->{rewritten}->{escaping} += $c || 0);
    ($c = s/\\"/"/g)
        && $stats && ($stats->{rewritten}->{escaping} += $c || 0);

    # functions
    ($c = s/ ?ON UPDATE \w+(?:\(\))?//gi)
        && $stats && ($stats->{dropped}->{on_update} += $c || 0);

    return ($_, $stats)
}

sub change_keys {
    $_ = shift;
    my $stats = shift;

    my $c;

    # PRIMARY KEY / UNIQUE / KEY / FOREIGN KEY
    if ($_  =~ /,\s*PRIMARY KEY \(`(\w+)`\)/) {
        $stats->{rewritten}->{primary_key}++
            if $stats;
        my $field = $1;
        $_  =~ s/,\s*PRIMARY KEY \(`\w+`\)//;
        $_  =~ s/(`$field`\s+\w+\s+NOT NULL\b)/$1 PRIMARY KEY/i;
    } 
    if ($_  =~ /,\s*UNIQUE KEY\s+`\w+`\s+\(`(\w+)`\)/) {
        $stats->{rewritten}->{unique_key}++
            if $stats;
        my $field = $1;
        $_  =~ s/,\s*UNIQUE KEY\s+`\w+`\s+\(`\w+`\)//;
        $_  =~ s/(`$field`\s+\w+\s+NOT NULL)/$1 UNIQUE/;
    }
    $c = s/,\s*KEY\s+`\w+`\s+\(`\w+`\)//gi || 0
        && $stats && ($stats->{dropped}->{key} += $c);
    $c = s/\bCONSTRAINT\s+`\w+`\s+FOREIGN KEY\s+\(`(\w+)`\)\s+REFERENCES\s+`(\w+)`\s+\(`(\w+)`\)/FOREIGN KEY($1) REFERENCES $2($3)/gi || 0
        && $stats && ($stats->{dropped}->{foreign_key} += $c);

    return $stats
        ? ($_, $stats)
        : $_;
}

sub change_specific {
    $_ = shift;
    my $stats = shift;

    my $c;
=head
    if ($_  =~ /\bCHECK\(\)\b/i) {
        $stats->{dropped}->{check}++;
        $_  =~ s/\bCHECK\(\)\b//i;
    }
=cut

    # DDL Engine
    $c = s/Engine=(\w+)\s*//i || 0
        && $stats && ($stats->{dropped}->{engine} += $c);
    $c = s/\s?AUTO_INCREMENT=(?:\d+)//gi || 0
        && $stats && ($stats->{dropped}->{autoincrement} += $c);
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
