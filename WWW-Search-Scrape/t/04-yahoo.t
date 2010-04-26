#!/usr/bin/perl -T

use Test::More qw/no_plan/;
use WWW::Search::Scrape::Yahoo;

BEGIN
{
    ok(WWW::Search::Scrape::Yahoo::search('bing', 10));
    ok(WWW::Search::Scrape::Yahoo::search('google', 10));
    ok(WWW::Search::Scrape::Yahoo::search('google', 22));
}
