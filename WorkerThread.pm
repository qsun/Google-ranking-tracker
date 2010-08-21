package WorkerThread;

use strict;
use warnings;

use Data::Dumper;

use threads;

use KeywordProtocol;
use WWW::Search::Scrape qw/:all/;

use FreezeThaw qw(freeze thaw);

sub start_worker($)
{
    my $domain = shift;
 TOP:
    while (my $keyword = $KeywordProtocol::q_main_worker->dequeue()) {
        warn $keyword;
        my $result = search({engine => 'google',
                             frontpage => 'http://www.google.com.au',
                             keyword => $keyword,
                             results => 100});
        my $rank = 0;

        foreach my $item (@{$result->{results}}) {
		warn('domain: ' . $domain . ' result: ' . $item);
            $rank++;
            if ($item =~ /$domain/i) {
		    warn('match: ' . $rank . ' keyword: ' . $keyword);
                $KeywordProtocol::q_worker_main->enqueue(freeze({rank =>$rank, keyword => $keyword}));
                next TOP;
            }
        }

        print $rank, "\n";

        $KeywordProtocol::q_worker_main->enqueue(freeze({rank => 1000, keyword => $keyword}));
    }
}

1;
