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
    my $path = path($repo);
    $path->exists or die "$path should be a repository path";
    my $catfile = $path->child( 'profiles', 'categories' );
    $catfile->is_file or die "$catfile should exist and be a category listing";
    return [ sort grep { $path->child($_)->is_dir }
          $catfile->lines_raw( { chomp => 1 } ) ];
}

1;

