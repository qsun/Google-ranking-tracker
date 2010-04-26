package WWW::Search::Scrape::Google;

use warnings;
use strict;

use Carp;

#use LWP::UserAgent;
use HTML::TreeBuilder;
use WWW::Mechanize;

=head1 NAME

  WWW::Search::Scrape::Google - Google search engine

=head1 VERSION

Version 0.07

=cut

our $VERSION = '0.07';

=head1 SYNOPSIS

You are not expected to use this module directly. Please use WWW::Search::Scrape instead.

=cut

=head1 FUNCTIONS

=head2 search

search is the most important function in this module.

Inputs

 +---------------------------+
 |        keyword            |
 +---------------------------+
 | desired number of results |
 +---------------------------+

Actually there is another optional argument, content, which is used in debug/test. It will replace LWP::UserAgent.

=cut

our $frontpage = 'http://www.google.com/ncr';
our $geo_location = '';

sub search($$;$)
{
    my ($keyword, $results_num, $content) = @_;
### search google using
###   keyword: $keyword
###   results number: $results_num
###   content: $content

    my $num = 0;

    if ($results_num >= 100) {
        carp 'WWW::Search::Scrape::Google can not process results more than 100.';
        return undef;
    }

    my @res;

    unless ($content)
    {
        my $mech = WWW::Mechanize->new(agent => 'NotWannaTellYou', cookie_jar => {});
        $mech->get($frontpage);
        #$mech->dump_forms;
        $mech->submit_form(
                           form_number => 1,
                           fields => {
                                      q => $keyword,
                                      num => $results_num,
                                      start => 0,
                                      gl => $geo_location
                                     },
                           button => 'btnG');
        if ($mech->success) {
            $content = $mech->response()->decoded_content();
        }
    }

    if (! $content)
    {
	    carp 'Failed to get content.';
	    return undef;
    }
    
    my $tree = HTML::TreeBuilder->new;
    $tree->parse($content);
    $tree->eof;

    # parse Google returned number
    {
        my ($xx) = $tree->look_down('_tag', 'div',
                                    sub
                                    {
                                        return unless $_[0]->attr('id') && $_[0]->attr('id') eq 'ssb';
                                    });

        carp 'Can not parse Google result.' unless $xx;
        my ($p) = $xx->look_down('_tag', 'p');
        carp 'Can not parse Google result.' unless $p && ref $p eq 'HTML::Element';
        my @r = $p->look_down('_tag', 'b');
        if (scalar @r <= 3) {
            ### No results.
            return {num => 0, results => undef};
        }

        @r = $r[2]->content_list;
        $num = join('', split(',', $r[0]));
        ### Google returns: $num
    }

    my @x = $tree->look_down('_tag', 'h3', 
			     sub {
                     return unless $_[0] && $_[0]->attr('class') && $_[0]->attr('class') eq 'r';
                     1;
			     });

    foreach (@x) {
        my ($link) = $_->look_down('_tag', 'a');
        push @res, $link->attr('href') unless $link->attr('href') =~ /^\//;
    }

### Result: @res
    return {num => $num, results => \@res};
}

1;
