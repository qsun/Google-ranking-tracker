#!/perl -T

use Test::More qw (no_plan);
use WWW::Search::Scrape::Google;

BEGIN
{
	ok(WWW::Search::Scrape::Google::search('google', 10));

	open GGFH, '<t/samples/google-result.html';
	my $content = join('', (<GGFH>));
	close GGFH;

	my $result = WWW::Search::Scrape::Google::search('google', 10, $content);

	ok($result->{num} == 622000000);

	open GGF, '<t/samples/google-no-result.htm';
	$content = join('', (<GGF>));
	close GGF;
	$result = WWW::Search::Scrape::Google::search('google', 10, $content);
	ok($result->{num} == 0);
}  
