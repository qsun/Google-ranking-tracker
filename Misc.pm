package Misc;

sub get_current_date()
{
    my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(time);
    my @abbr = qw( Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec );
    return "" . $mday . ' '. $abbr[$mon] . ' ' . ($year + 1900);
}


1;
