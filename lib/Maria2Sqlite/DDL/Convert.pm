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
    $c = s/\s+(?:un)?signed//gi || 0
        && $stats && ($stats->{rewritten}->{signed} += $c);
    $c = s/\bAUTO_INCREMENT\b/AUTOINCREMENT/gi || 0
        && $stats && ($stats->{rewritten}->{autoincrement} += $c);
    $c = s/\(\s*\)//g || 0
        && $stats && ($stats->{rewritten}->{function_brackets} += $c);

    # INTEGER
    $c = s/\bbit\(\d+\)/integer/gi || 0
        && $stats && ($stats->{rewritten}->{type_integer} += $c);
    $c = s/\bbigint\(\d+\)/integer/gi || 0
        && $stats && ($stats->{rewritten}->{type_integer} += $c);
    $c = s/\bbool\b/integer/gi || 0
        && $stats && ($stats->{rewritten}->{type_integer} += $c);
    $c = s/\bboolean\b/integer/gi || 0
        && $stats && ($stats->{rewritten}->{type_integer} += $c);
    $c = s/\bint\(\d+\)/integer/gi|| 0
        && $stats && ($stats->{rewritten}->{type_integer} += $c);
    $c = s/\bint\d\b/integer/gi || 0
        && $stats && ($stats->{rewritten}->{type_integer} += $c);
    $c = s/\bint\b/integer/gi || 0
        && $stats && ($stats->{rewritten}->{type_integer} += $c);
    $c = s/\binteger\(\d\)/integer/gi || 0
        && $stats && ($stats->{rewritten}->{type_integer} += $c);
    $c = s/\binteger\b/integer/gi || 0
        && $stats && ($stats->{rewritten}->{type_integer} += $c);
    $c = s/\bmediumint\(\d+\)/integer/gi || 0
        && $stats && ($stats->{rewritten}->{type_integer} += $c);
    $c = s/\bmediumint\b/integer/gi || 0
        && $stats && ($stats->{rewritten}->{type_integer} += $c);
    $c = s/\bmiddleint\(\d+\)/integer/gi || 0
        && $stats && ($stats->{rewritten}->{type_integer} += $c);
    $c = s/\bmiddleint\b/integer/gi || 0
        && $stats && ($stats->{rewritten}->{type_integer} += $c);
    $c = s/\bserial\b/integer NOT NULL AUTO_INCREMENT/gi || 0
        && $stats && ($stats->{rewritten}->{type_integer} += $c);
    $c = s/\bsmallint\(\d+\)/integer/gi || 0
        && $stats && ($stats->{rewritten}->{type_integer} += $c);
    $c = s/\bsmallint\b/integer/gi || 0
        && $stats && ($stats->{rewritten}->{type_integer} += $c);
    $c = s/\btinyint\(\d+\)/integer/gi || 0
        && $stats && ($stats->{rewritten}->{type_integer} += $c);
    $c = s/\btinyint\b/integer/gi || 0
        && $stats && ($stats->{rewritten}->{type_integer} += $c);

    # NUMERIC
    $c = s/\bdec\s*\(\d+,\d+\)/numeric/gi || 0
        && $stats && ($stats->{rewritten}->{type_numeric} += $c);
    $c = s/\bdec\b/numeric/gi || 0
        && $stats && ($stats->{rewritten}->{type_numeric} += $c);
    $c = s/\bdecimal\s*\(\d+(,\d+)?\)/numeric/gi || 0
        && $stats && ($stats->{rewritten}->{type_numeric} += $c);
    $c = s/\bdecimal\b/numeric/gi || 0
        && $stats && ($stats->{rewritten}->{type_numeric} += $c);
    $c = s/\bfixed\s*\(\d+,\d+\)/numeric/gi || 0
        && $stats && ($stats->{rewritten}->{type_numeric} += $c);
    $c = s/\bfixed\b/numeric/gi || 0
        && $stats && ($stats->{rewritten}->{type_numeric} += $c);
    $c = s/\bnumeric\s*\(\d+(,\d+)?\)/numeric/gi || 0
        && $stats && ($stats->{rewritten}->{type_numeric} += $c);
    $c = s/\bnumeric\b/numeric/gi || 0
        && $stats && ($stats->{rewritten}->{type_numeric} += $c);

    # REAL / FLOATING POINT
    $c = s/\bfloat\s*\(\d+(,\d+)?\)/real/gi || 0
        && $stats && ($stats->{rewritten}->{type_real} += $c);
    $c = s/\bfloat\b/real/gi || 0
        && $stats && ($stats->{rewritten}->{type_real} += $c);
    $c = s/\bdouble(\s+precision)?\(\d+(,\d+)?\)/real/gi || 0
        && $stats && ($stats->{rewritten}->{type_real} += $c);
    $c = s/\bdouble(\s+precision)?\b/real/gi || 0
        && $stats && ($stats->{rewritten}->{type_real} += $c);
    $c = s/\breal\s*\(\d+(,\d+)?\)/real/gi || 0
        && $stats && ($stats->{rewritten}->{type_real} += $c);
    $c = s/\breal\b/real/gi || 0
        && $stats && ($stats->{rewritten}->{type_real} += $c);

    # DATE / TIME / DATETIME / TIMESTAMP
    $c = s/\bdate\b/text/gi || 0
        && $stats && ($stats->{rewritten}->{type_datetime} += $c);
    $c = s/\bdatetime\s*\(\d+\)/text/gi || 0
        && $stats && ($stats->{rewritten}->{type_datetime} += $c);
    $c = s/\bdatetime\b/text/gi || 0
        && $stats && ($stats->{rewritten}->{type_datetime} += $c);
    $c = s/\btime\s*\(\d+\)/text/gi || 0
        && $stats && ($stats->{rewritten}->{type_datetime} += $c);
    $c = s/\btime\b/text/gi || 0
        && $stats && ($stats->{rewritten}->{type_datetime} += $c);
    $c = s/\btimestamp\s*\(\d+\)/text/gi || 0
        && $stats && ($stats->{rewritten}->{type_datetime} += $c);
    $c = s/\btimestamp\b/text/gi || 0
        && $stats && ($stats->{rewritten}->{type_datetime} += $c);
    $c = s/\byear\s*\(\d+\)/integer/gi || 0
        && $stats && ($stats->{rewritten}->{type_datetime} += $c);
    $c = s/\byear\b/integer/gi || 0
        && $stats && ($stats->{rewritten}->{type_datetime} += $c);

    # convert some  synonyms
    $c = s/\bn?char varying(\(\d+\))/varchar$1/gi || 0
        && $stats && ($stats->{rewritten}->{synonyms} += $c);
    $c = s/\bclob\b/longtext/gi || 0
        && $stats && ($stats->{rewritten}->{synonyms} += $c);

    # BLOB TYPES
    $c = s/\bbinary\(\d+\)/blob/gi || 0
        && $stats && ($stats->{rewritten}->{type_blob} += $c);
    $c = s/\bblob\(\d+\)/blob/gi || 0
        && $stats && ($stats->{rewritten}->{type_blob} += $c);
    $c = s/\bblob\b/blob/gi || 0
        && $stats && ($stats->{rewritten}->{type_blob} += $c);
    $c = s/\bchar byte\b/blob/gi || 0
        && $stats && ($stats->{rewritten}->{type_blob} += $c);
    $c = s/\blongblob\b/blob/gi || 0
        && $stats && ($stats->{rewritten}->{type_blob} += $c);
    $c = s/\blong varbinary\b/blob/gi || 0
        && $stats && ($stats->{rewritten}->{type_blob} += $c);
    $c = s/\bmediumblob\b/blob/gi || 0
        && $stats && ($stats->{rewritten}->{type_blob} += $c);
    $c = s/\braw\(\d+\)/blob/gi || 0
        && $stats && ($stats->{rewritten}->{type_blob} += $c);
    $c = s/\btinyblob\b/blob/gi || 0
        && $stats && ($stats->{rewritten}->{type_blob} += $c);
    $c = s/\bvarbinary\(\d+\)/blob/gi || 0
        && $stats && ($stats->{rewritten}->{type_blob} += $c);

    # TEXT TYPES
    $c = s/\benum\s*\([^)]+\)/text/gi || 0
        && $stats && ($stats->{rewritten}->{type_text} += $c);
    $c = s/\binet[46]\b/text/gi || 0
        && $stats && ($stats->{rewritten}->{type_text} += $c);
    $c = s/\bjson\b/text/gi || 0
        && $stats && ($stats->{rewritten}->{type_text} += $c);
    $c = s/\blong(?:\s+(?:char varying|character varying|varchar|varcharacter))?\b/text/gi || 0
        && $stats && ($stats->{rewritten}->{type_text} += $c);
    $c = s/\blongtext\b/text/gi || 0
        && $stats && ($stats->{rewritten}->{type_text} += $c);
    $c = s/\bmediumtext\b/text/gi || 0
        && $stats && ($stats->{rewritten}->{type_text} += $c);
    $c = s/\bnational\s+(?:char varying|character varying|varchar|varcharacter)\(\d+\)/text/gi || 0
        && $stats && ($stats->{rewritten}->{type_text} += $c);
    $c = s/\b(?:nchar\s+)?varchar(?:acter)?\(\d+\)/text/gi || 0
        && $stats && ($stats->{rewritten}->{type_text} += $c);
    $c = s/\bset\s*\([^)]+\)/text/gi || 0
        && $stats && ($stats->{rewritten}->{type_text} += $c);
    $c = s/\btext(?:\(\d+\))/text/gi || 0
        && $stats && ($stats->{rewritten}->{type_text} += $c);
    $c = s/\btext\b/text/gi || 0
        && $stats && ($stats->{rewritten}->{type_text} += $c);
    $c = s/\btinytext\b/text/gi || 0
        && $stats && ($stats->{rewritten}->{type_text} += $c);
    $c = s/\buuid\b/text/gi || 0
        && $stats && ($stats->{rewritten}->{type_text} += $c);
    $c = s/\bvarchar2\(\d+\)/text/gi || 0
        && $stats && ($stats->{rewritten}->{type_text} += $c);
    $c = s/\bn?varchar(?:acter)?\(\d+\)/text/gi || 0
        && $stats && ($stats->{rewritten}->{type_text} += $c);
    $c = s/\b(national\s+)?char\(\d+\)/text/gi || 0
        && $stats && ($stats->{rewritten}->{type_text} += $c);
    $c = s/\b(?:national\s+)?char(?:acter)?\b/text/gi || 0
        && $stats && ($stats->{rewritten}->{type_text} += $c);
    $c = s/\bn?char(?:\s+varying)?\(\d+\)/text/gi || 0
        && $stats && ($stats->{rewritten}->{type_text} += $c);
    $c = s/\bnchar\b/text/gi || 0
        && $stats && ($stats->{rewritten}->{type_text} += $c);

    return $stats
        ? ($_, $stats)
        : $_;
}

sub change_others {
    $_ = shift;
    my $stats = shift;

    my $c;
    
    $c = s/\\'/''/g || 0
        && $stats && ($stats->{rewritten}->{escaping} += $c);
    $c = s/\\"/"/g || 0
        && $stats && ($stats->{rewritten}->{escaping} += $c);

    # functions
    $c = s/ ?ON UPDATE \w+(?:\(\))?//gi || 0
        && $stats && ($stats->{dropped}->{on_update} += $c);

    return $stats
        ? ($_, $stats)
        : $_;
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
