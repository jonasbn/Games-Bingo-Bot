use ExtUtils::MakeMaker;

# $Id: Makefile.PL,v 1.2 2003/06/25 20:57:27 jonasbn Exp $

WriteMakefile(
    'NAME'	        => 'Games::Bingo::Bot',
    'VERSION_FROM'  => 'lib/Games/Bingo/Bot.pm', # finds $VERSION
	'PREREQ_PM' => {
		'Test::Harness' => 0,
		'Test::More'    => 0,
		'Test::Pod'     => '0.95',
		'Games::Bingo'	=> '0.05',
	}
);
