use 5.006;    # our
use strict;
use warnings;

package Gentoo::Atom::Scraper::Arches;

our $VERSION = '0.001000';

# ABSTRACT: Return list of recognized arch tokens from repo

# AUTHORITY

use Path::Tiny qw( path );

sub scrape {
    my ( $self, $repo ) = @_;
    my (@out);
    $self->foreach( $repo, sub { push @out, $_[0] } );
    return [ sort @out ];
}

sub foreach {
    my ( $self, $repo, $callback ) = @_;
    my $path = path($repo);
    $path->exists or die "$path should be a repository path";
    my $archfile = $path->child( 'profiles', 'arch.list' );
    $archfile->is_file or die "$archfile should exist and be an arch listing";
    my $fh = $archfile->openr_raw;
    while ( my $line = <$fh> ) {
        chomp $line;
        $line =~ s/\s*#.*\z//;
        next if $line =~ /\A\s*\z/;
        $callback->($line);
    }
}

1;

