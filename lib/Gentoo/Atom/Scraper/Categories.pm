use 5.006;    # our
use strict;
use warnings;

package Gentoo::Atom::Scraper::Categories;

our $VERSION = '0.001000';

# ABSTRACT: Scrape Categories from a Gentoo Repository

# AUTHORITY

use Path::Tiny qw( path );

sub scrape {
    my ( $self, $repo ) = @_;
    my (@out);
    $self->foreach(
        $repo,
        sub {
            push @out, $_[0];
        }
    );
    return [ sort @out ];
}

sub foreach {
    my ( $self, $repo, $callback ) = @_;
    my $path = path($repo);
    $path->exists or die "$path should be a repository path";
    my $catfile = $path->child( 'profiles', 'categories' );
    $catfile->is_file or die "$catfile should exist and be a category listing";
    my $fh = $catfile->openr_raw;
    while ( my $line = <$fh> ) {
        chomp $line;
        next unless $path->child($line)->is_dir;
        $callback->($line);
    }
}

1;

