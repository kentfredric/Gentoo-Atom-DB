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
    my (@out);
    $self->foreach(
        $repository => sub {
            push @out, "$_[0]/$_[1]";
        }
    );
    return [ sort @out ];
}

sub scrape_category_full {
    my ( $self, $repository, $category ) = @_;
    my @out;
    $self->foreach_category(
        $repository => $category => sub {
            push @out, "$category/$_[0]";
        }
    );
    return [ sort @out ];
}

sub scrape_category_short {
    my ( $self, $repository, $category ) = @_;
    my @out;
    $self->foreach_category(
        $repository,
        $category,
        sub {
            push @out, $_[0];
        }
    );
    return [ sort @out ];
}

sub foreach {
    my ( $self, $repository, $callback ) = @_;
    Gentoo::Atom::Scraper::Categories->foreach(
        $repository => sub {
            my $category = $_[0];
            $self->foreach_category(
                $repository => $category => sub {
                    $callback->( $category, $_[0] );
                }
            );
        }
    );
}

sub foreach_category {
    my ( $self, $repository, $category, $callback ) = @_;
    opendir my $dfh, path( $repository, $category )->absolute->stringify;
    while ( my $nodename = readdir $dfh ) {
        next if $nodename eq '.' or $nodename eq '..';
        next unless path( $repository, $category, $nodename )->is_dir;
        $callback->($nodename);
    }
}

1;

