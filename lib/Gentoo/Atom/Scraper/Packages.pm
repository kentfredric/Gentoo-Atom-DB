use 5.006;    # our
use strict;
use warnings;

package Gentoo::Atom::Scraper::Packages;

our $VERSION = '0.001000';

# ABSTRACT: Scrape package names from repositories

# AUTHORITY

use Gentoo::Atom::Scraper::Categories;
use Path::Tiny qw( path );

sub scrape {
    my ( $self, $repository ) = @_;
    return [ map { $self->scrape_category_full($_) }
          @{ Gentoo::Atom::Scraper::Categories->scrape($repository) } ];
}

sub scrape_category_full {
    my ( $self, $repository, $category ) = @_;
    return [ map { "$category/$_" }
          @{ $self->scrape_category_short( $repository, $category ) } ];
}

sub scrape_category_short {
    my ( $self, $repository, $category ) = @_;
    return [ sort map { $_->basename }
          grep { $_->is_dir } path( $repository, $category )->children ];
}

1;

