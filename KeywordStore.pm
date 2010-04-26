package KeywordStore;

use strict;
use warnings;

use Data::Dumper;
use Misc;

# how data is stored in system

use DBI;

our $dbh;

sub connect() 
{
    my $dbh_self = DBI->connect("dbi:SQLite:dbname=keyworddb", "", "");
    $dbh = $dbh_self;
    return $dbh_self;
}

sub get_keywords($)
{
    my $dbh = shift;

    my @keywords;

    my $sth = $dbh->prepare("SELECT keyword FROM keywords");
    $sth->execute();
    while (my $ref = $sth->fetchrow_hashref()) {
        push @keywords, $ref->{keyword};
    }

    warn Dumper(\@keywords);

    return \@keywords;
}

sub add_keyword($$) 
{
    my ($dbh, $keyword) = @_;
    
    my $sth = $dbh->prepare('INSERT INTO keywords (keyword) VALUES (?)');
    $sth->execute($keyword);
}

sub del_keyword($$)
{
    my ($dbh, $keyword) = @_;
    
    my $sth = $dbh->prepare('DELETE FROM keywords WHERE keyword = ?');
    $sth->execute($keyword);
}

sub set_ranks($$$$$)
{
    my ($dbh, $keyword, $date, $se, $rank) = @_;
    my $sth = $dbh->prepare("INSERT INTO records (keyword, date, se, rank) VALUES (?, ?, ?, ?)");
    $sth->execute($keyword, $date, $se, $rank);
    return;
}

sub get_ranks($$$$)
{
    my ($dbh, $keyword, $date, $se) = @_;
    my $sth = $dbh->prepare("SELECT max(rank) AS rank FROM records WHERE keyword = ? AND date = ? AND se = ?");
    $sth->execute($keyword, $date, $se);
    warn($keyword, $date, $se);
    while (my $ref = $sth->fetchrow_hashref()) {
        warn Dumper($ref);
        return $ref->{rank};
    }

    print "N/A\n";
    return undef;
}

sub get_domain($)
{
    my ($dbh) = @_;

    my $sth = $dbh->prepare('SELECT * FROM domains');
    $sth->execute;
    while (my $ref = $sth->fetchrow_hashref()) {
        return $ref->{domain};
    }

    return 'Please input your site domain here';
}

sub set_domain($$)
{
    my ($dbh, $domain) = @_;
    
    my $sth = $dbh->prepare('DELETE FROM domains');;
    $sth->execute();

    $sth = $dbh->prepare('INSERT INTO domains (domain) VALUES (?)');
    $sth->execute($domain);
    
    return;
}

sub get_dates($)
{
    my ($dbh) = @_;
    my $sth = $dbh->prepare("SELECT DISTINCT date AS d FROM records");
    $sth->execute();
    
    my @dates;
    my $exist = undef;
    my $today = Misc::get_current_date();
    while (my $ref = $sth->fetchrow_hashref) {
        push @dates, $ref->{d};
        if ($ref->{d} eq $today) {
            $exist = 1;
        }
    }

    unless ($exist) {
        push @dates, $today;
    }

    return \@dates;
}

1;
