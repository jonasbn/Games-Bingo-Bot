#!/usr/bin/perl 

# $Id: bingobot.pl,v 1.5 2003/06/25 21:12:16 jonasbn Exp $

use warnings;
use strict;
use POE;
use POE::Component::IRC;
use lib qw(../lib lib);
use Games::Bingo::Bot;

use constant ANY     => 1;
use constant PUBLIC  => 2;
use constant PRIVATE => 3;

POE::Component::IRC->new("irc");

my $gbb = Games::Bingo::Bot->new();

POE::Session->new(
    _start     => \&bot_start,
    irc_001    => \&on_connect,
    irc_public => \&on_public,
    irc_msg    => \&on_private
);

$poe_kernel->run();

exit(0);

sub CHANNEL () { "#bingo" }

sub bot_start {
    my $kernel  = $_[KERNEL];
    my $heap    = $_[HEAP];
    my $session = $_[SESSION];
    $kernel->post( irc => register => "all" );

    $kernel->post(
        irc => connect => {
            Nick     => 'bingobot',
            Username => 'bingobot',
            Ircname  => 'Games::Bingo IRC Bot',
            Server   => 'grou.ch',
            Port     => '6667',
        }
    );
	_writelog("","","Connecting...");
}

sub on_connect {
    $_[KERNEL]->post( irc => join => CHANNEL );
    _writelog("","","Joining channel...");
}

sub on_private {
    my ($kernel, $who, $where, $msg) = @_[ KERNEL, ARG0, ARG1, ARG2 ];

    my $nick    = ( split /!/,$who )[0];
    my $channel = $where->[0];

	_writelog($nick, $channel, $msg);			

	_proces($kernel, $msg, $nick, $nick);
}

sub on_public {
    my ($kernel, $who, $where, $msg) = @_[ KERNEL, ARG0, ARG1, ARG2 ];

    my $nick    = ( split /!/,$who )[0];
    my $channel = $where->[0];
    
    _writelog($nick, $channel, $msg);

	_proces($kernel, $msg, $nick, $channel);
}    

sub _writelog {
	my ($nick, $channel, $msg) = @_;
	
	my $ts = scalar(localtime);
	print "[$ts] <$nick:$channel> $msg\n";
}

sub _proces {
	my ($kernel, $msg, $nick, $channel) = @_;
		
    if (my $sub = $gbb->{'commands'}->{$msg}) {
    	    	
    	my ($type, $answer) = &$sub($gbb, $nick);
	
		if ($type == PRIVATE) {
			$channel = $nick;
		} elsif ($type == PUBLIC) {
			$channel = CHANNEL;
		} elsif ($type == ANY) {
			#we answer the way we got queried
		} else {
			$channel = $nick;
			_writelog($nick, $channel, "Unknown channel ($msg)");
		}
		if ($answer =~ m/\n/) {
			_output_multiline($kernel, $msg, $nick, $channel, $answer);
		} else {
			_output($kernel, $msg, $nick, $channel, $answer);
		}
    } else {
    	my $answer = "$nick: You called me with unknown command $msg\n";
    	$answer .= "msg me the command help for further assistance";

    	_output_multiline($kernel, $msg, $nick, $nick, $answer);
    }
}

sub _output_multiline {
	my ($kernel, $msg, $nick, $channel, $output) = @_;

	my @lines = split(/\n/, $output);
	
	foreach my $line (@lines) {
		$kernel->post( irc => privmsg => $channel, $line);
	}
}

sub _output {
	my ($kernel, $msg, $nick, $channel, $output) = @_;

	$kernel->post( irc => privmsg => $channel, $output);
}

__END__

=head1 NAME

bingobot.pl - A simple IRC bot for playing bingo

=cut

=head1 SYNOPSIS

% bingobot.pl

=cut

=head1 DESCRIPTION

This is a simple bot running an online game of bingo via IRC.

The main documentation is located in the Games::Bingo::Bot class.

=cut

=head1 SEE ALSO

=over 4

=item *

Games::Bingo

=item *

Games::Bingo::Bot

=item *

POE::Component::IRC

=back

=cut

=head1 TODO

Please refer to the TODO file or the listing in Games::Bingo::Bot

=cut

=head1 AUTHOR

jonasbn E<lt>jonasbn@cpan.orgE<gt>

=cut

=head1 COPYRIGHT

Games::Bingo::Bot and related modules are free software and is released under
the Artistic License. See
E<lt>http://www.perl.com/language/misc/Artistic.htmlE<gt> for details.

Games::Bingo::Bot is (C) 2003 Jonas B. Nielsen (jonasbn)
E<lt>jonasbn@cpan.orgE<gt>

=cut