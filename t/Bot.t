#!/usr/bin/perl 

# $Id: Bot.t,v 1.2 2003/06/25 20:57:27 jonasbn Exp $

use warnings;
use strict;
use Data::Dumper;
use Test::More tests => 27;

use constant ANY     => 1;
use constant PUBLIC  => 2;
use constant PRIVATE => 3;

use lib qw(../lib lib);

#test 1-2
BEGIN { use_ok( 'Games::Bingo::Bot' ); }
require_ok( 'Games::Bingo::Bot' );

#test 3
my $gbb = Games::Bingo::Bot->new();

is(ref $gbb, 'Games::Bingo::Bot', 'Testing the constructor');

#print STDERR Dumper $gbb;

my ($type, $answer) = undef;
my $nick = "player1";

#test 4 get_sub
my $sub = $gbb->get_sub("stats");

is(ref $sub, 'CODE', 'testing a coderef');

#test 5-6  bingo
($type, $answer) = $gbb->pull($nick);

is($type, PUBLIC, 'testing the type');

like($answer, qr/\w+/, 'testing the answer'); 

#test 7-8 pulled
($type, $answer) = $gbb->pulled($nick);

is($type, ANY, 'testing the type');

like($answer, qr/\w+/, 'testing the answer'); 

#test 9-10 pull
($type, $answer) = $gbb->play($nick);

is($type, ANY, 'testing the type');

like($answer, qr/\w+/, 'testing the answer'); 

#test 11-12 play
($type, $answer) = $gbb->play($nick);

is($type, PRIVATE, 'testing the type');

like($answer, qr/\w+/, 'testing the answer'); 

#test 13-14 show
($type, $answer) = $gbb->play($nick);

is($type, PRIVATE, 'testing the type');

like($answer, qr/\w+/, 'testing the answer'); 

#test 15-16 stats
($type, $answer) = $gbb->stats($nick);

is($type, ANY, 'testing the type');

like($answer, qr/\w+/, 'testing the answer'); 

#test 17-19 part
($type, $answer) = $gbb->part($nick);

is($type, ANY, 'testing the type');

like($answer, qr/\w+/, 'testing the answer'); 

ok(! $gbb->{'players'}->{$nick}, 'testing players list');

#test 20-22 auto
($type, $answer) = $gbb->auto();

is($type, PUBLIC, 'testing the type');

like($answer, qr/\w+/, 'testing the answer'); 

is($gbb->{'auto'}, 1, 'testing the autoflag');

#test 23-25 noauto
($type, $answer) = $gbb->noauto();

is($type, PUBLIC, 'testing the type');

like($answer, qr/\w+/, 'testing the answer'); 

is($gbb->{'auto'}, 0, 'testing the autoflag');

#test 26-27 help
($type, $answer) = $gbb->help();

is($type, PRIVATE, 'testing the type');

like($answer, qr/\n/, 'testing the answer'); 