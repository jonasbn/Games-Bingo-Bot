package Games::Bingo::Bot;

# $Id: Bot.pm,v 1.4 2003/06/25 21:12:16 jonasbn Exp $

use strict;
use warnings;
use vars qw($VERSION);
use lib qw(/Users/jonasbn/Develop/Copenhagen/modules/Games/Bingo/lib);
use Games::Bingo;
use Games::Bingo::Card;

$VERSION = '0.01';

use constant ANY     => 1;
use constant PUBLIC  => 2;
use constant PRIVATE => 3;

sub new {
	my $class = shift;

	my $self = bless {
		commands => {
			play   => \&play,
			bingo  => \&bingo,
			show   => \&show,
			pull   => \&pull,
			stats  => \&stats,
			pulled => \&pulled,
			part   => \&part,
			help   => \&help,
			auto   => \&auto,
			noauto => \&noauto,
		},
		players => {},
		sleepinterval => 0,
		auto => 0,
	}, ref $class || $class;
	
	$self->{'bingo'} = Games::Bingo->new(90);
	
	return $self;
}

sub get_sub {
	my ($self, $msg) = @_;
	
	return $self->{commands}->{$msg}; 
}

sub bingo {
    my ($self, $nick) = @_;

	my $card = $self->{'players'}->{$nick};

	if ($card->validate($self->{'bingo'})) {
		return (PUBLIC, "WE HAVE A WINNER! - $nick, congrats!");
	} else {
		return (PRIVATE, "$nick: sorry no bingo, keep your eyes on the game");	
	}
}

sub pulled {
	my ($self, $nick) = @_;

	my $output = "$nick: These numbers have been pulled: ";
	my @pulled = sort({$b <=> $a} $self->{'bingo'}->_all_pulled());
	while (@pulled) {	
		$output .= pop @pulled; 
		$output .= ", " if (scalar @pulled);
	}
	return (ANY, $output);
}

sub pull {
	my ($self, $nick) = @_;
    
    my $number = $self->{'bingo'}->play();
          
    return (PUBLIC, "Number $number");
}

sub play {
	my ($self, $nick) = @_;

    if ($self->{'players'}->{$nick}) {
        return (PRIVATE, "$nick: I am sorry, but you are already in the game");
        
	} else {
		my $b = Games::Bingo->new(90);
		my $card = Games::Bingo::Card->new($b);
		$self->{'players'}->{$nick} = $card;
		
		return (ANY, "$nick: welcome in the game");
	}
}

sub show {
	my ($self, $nick) = @_;

	if (exists $self->{'players'}->{$nick}) {
		my $card = $self->{'players'}->{$nick};
	
		my $output = "$nick: These are your numbers: ";
		my @numbers = sort({$b <=> $a} @{$card});
		while (@numbers) {	
			$output .= pop @numbers; 
			$output .= ", " if (scalar @numbers);
		}
		return (PRIVATE, $output);
	} else {
        return (PRIVATE, "$nick: I am sorry, but you are not in the game");	
	}
}

sub stats {
	my ($self, $nick) = @_;
	
	my $output = "$nick: ";
	my $pulled = scalar($self->{'bingo'}->_all_pulled());
	my $remaining = scalar(@{$self->{'bingo'}->{'_numbers'}});
	my $players = keys(%{$self->{'players'}});

	$output = "Players: $players Pulled: $pulled Remaining: $remaining";

	return (ANY, $output);
}

sub part {
	my ($self, $nick) = @_;
	
	delete $self->{'players'}->{$nick};
	
	return (ANY, "$nick: you have left the game");
}

sub auto {
	my $self = shift;
	
	$self->{'auto'}++;
	
	return (PUBLIC, "Auto pulling enabled");
}

sub noauto {
	my $self = shift;

	$self->{'auto'}--;

    return (PUBLIC, "Auto pulling disabled");
}

sub help {
		
	my $help = qq[
These are the bingobot commands:

help   - this message
play   - join a game
stats  - get the current statistics of the running game
pull   - pull the next number
bingo  - you indicate to the bot that you have bingo
pulled - shows you what number have been pulled
show   - lists the numbers on your plate

Not implemented yet:

auto   - enables automode (automatic number pulling)
noauto - disables automode
	
All commands can be sent into the channel or send as private messages
to the bot. The bot can repond as both of these ways aswell. The
reponses are sent as follows:

	- help, show and all errors are always private messages
	
	- pull and bingo are always public
	
	- play, pulled, stats, auto, noauto depends on how you query

As long as the bot is online a game is running /EOM.
];

	return (PRIVATE, $help);
}

__END__

=head1 NAME

Games::Bingo::Bot - A simple class holding IRC related methods for bingo

=cut

=head1 SYNOPSIS

use Games::Bingo::Bot;

use constant ANY     =E<gt> 1;
use constant PUBLIC  =E<gt> 2;
use constant PRIVATE =E<gt> 3;

my $gbb = Games::Bingo::Bot-E<gt>new();

my $sub = $gbb-E<gt>{'commands'}-E<gt>{$msg});

my ($type, $answer) = &$sub($gbb, $nick);

=cut

=head1 DESCRIPTION

This module contains all the commands supported by the
Games::Bingo::Bot IRC bot (see the script in the bin directory).

The Games::Bingo::Bot class (this) and the script mentioned above is a
complete IRC setup for playing Bingo, using the Games::Bingo module.

These are the bingobot commands:

=over 4

=item *

help   - this message

=item *

play   - join a game

=item *

stats  - get the current statistics of the running game

=item *

pull   - pull the next number

=item *

bingo  - you indicate to the bot that you have bingo

=item *

pulled - shows you what number have been pulled

=item *

show   - lists the numbers on your plate

=back

The command are described below in detail (SEE COMMANDS).

Not implemented yet (SEE TODO):

=over 4

=item *

auto   - enables automode (automatic number pulling)

=item *

noauto - disables automode

=back
	
All commands can be sent into the channel or send as private messages
to the bot. The bot can repond as both of these ways aswell. The
reponses are sent as follows:

=over 4

=item *

help, show and all errors are always private messages

=item *
	
pull and bingo are always public

=item *
	
play, pulled, stats, auto, noauto depends on how you query

=back

As long as the bot is online a game is running.

=cut

=head2 METHODS

These are the basic methods of the class.

=cut

=head2 new

This is the constructor, it will start up a new game.

=cut

=head2 get_sub

This is the only method apart from the contructor new, which is not a
implementation of a IRC related command. 

The method returns a CODEREF to the command asked for (SEE COMMANDS).

=cut

=head2 COMMANDS

All these methods are implementations of commands which are supported by the IRC client.

=cut

=head2 bingo

This is the command to be issued by a user, when he/she has bingo.

This starts a check of the issuing players card.

The method takes one argument, the nick of the player.

The methods reponds publicly on success and privately when the player
did not have a bingo.

=cut

=head2 pull

This command issues the pulling of a new number.

The method takes no arguments. The method responds publicly.

=cut

=head2 show

This command shows the card of the player issuing the command.

The method takes one argument, the nick of the player. The method
reponds privately.

=cut

=head2 stats

This command shows the current stats of the game.

=over 4

=item *

Number of players

=item *

Number of numbers pulled

=item *

Number of numbers remaining

=back

The method takes no arguments. The method responds according to how it
was called (publicly/privately).

=cut

=head2 pulled

This method shows the numbers which have been pulled.

The method takes no arguments. The method responds according to how it
was called (publicly/privately).

=cut

=head2 play

This method adds the issuing player to the current game.

The method takes one argument, the nick of the player. The method
responds according to how it was called (publicly/privately).

=cut

=head2 part

This method deletes the issueing player from the current game.

The method takes one argument, the nick of the player. The method
responds according to how it was called (publicly/privately).

=cut

=head2 auto 

*This is not yet implemented, please see the TODO*

This is actually a simple accessor, enabling the autoflag of the game,
meaning numbers are pulled automatically.

The method takes no argument. The method responds according to how it
was called (publicly/privately).

=cut

=head2 noauto

*This is not yet implemented, please see the TODO*

This is actually a simple accessor, disabling the autoflag of the game,
meaning numbers are no longer pulled automatically.

The method takes no argument. The method responds according to how it
was called (publicly/privately).

=cut

=head2 help

This is a simple list of the commands and a few guidelines, a reference
manual so to speak.

The method takes no argument. The method responds privately.

=cut

=head1 SEE ALSO

=over 4

=item *

Games::Bingo

=item *

Games::Bingo::Card

=item *

POE::Component::IRC

=item *

bin/bingobot.pl

=back

=cut

=head1 TODO

=over 4

=item *

Implement use of App::Config or a similar module for easier
configuration and use

=item *

Implement auto and noauto commands. At this time I am not sure how this
should be done. Should it be done using a child process to run the
game, or should I just implement a sort of broadcast functionality?

=back

=over 8

=item *

Child processes: http://poe.perl.org/?POE_Cookbook/Child_Processes

=item *

Broadcast: http://poe.perl.org/?POE_Cookbook/Broadcasting_Events

=item *

Or should this be done by using IRC as communication media, reacting on
own commands, ugly but simple :)

=back

=over 4

=item *

Implement handling of nick changes so a game follows a user

=item *

Implement user check so in case of spontane disconnects followed by
connects a user can resume a game under his new nick

=item *

Implement resuming of running game after spontaneous disconnect of the 
bot

=item *

Write tests of the IRC commands (should these go into a module?)

=item *

Write docs

=item *

Implement functionality to start a new game automatically when a game
is over. This could be done by pilfering with the constructor

=item *

Implement point system (should "bingo" commands issue negative points
when the player does not have bingo?)

=item *

Improve the output of the 'pulled' command so it shows a more console
like output (see Games::Bingo, the bingo.pl script)

=item *

Improve the output of the 'show' command to show a console like card

=item *

Add a 'rules' command

=item *

Should all commands be prefix with the name of the bot? now it would
trigger on alot of works. So if it is supposed to run in a public
channel it could prove annoying.

=back

=cut

=head1 AUTHOR

jonasbn E<lt>jonasbn@cpan.orgE<gt>

=cut

=head1 COPYRIGHT

Games::Bingo::Bot and related scripts and modules are free software and
is released under the Artistic License. See
E<lt>http://www.perl.com/language/misc/Artistic.htmlE<gt> for details.

Games::Bingo::Bot is (C) 2003 Jonas B. Nielsen (jonasbn)
E<lt>jonasbn@cpan.orgE<gt>

=cut

1;