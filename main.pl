use Wx;
use strict;

use MainFrame;

package MyApp;

use base qw(Wx::App);
use strict;

sub OnInit {
	my( $self ) = shift;

	Wx::InitAllImageHandlers();

	my $main_frame = MainFrame->new();
    $main_frame->Show(1);

	return 1;
}
# end of class MyApp

package main;

use KeywordProtocol;
use WorkerThread;

my $dbh = KeywordStore::connect();
my $domain = KeywordStore::get_domain($dbh);

threads->create('WorkerThread::start_worker', $domain);

unless(caller){
	my $app = MyApp->new();

	$app->MainLoop();
}
