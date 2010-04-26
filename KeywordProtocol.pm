package KeywordProtocol;

use strict;
use warnings;

use threads;
use Thread::Queue;

our $q_main_worker = Thread::Queue->new();
our $q_worker_main = Thread::Queue->new();

1;
