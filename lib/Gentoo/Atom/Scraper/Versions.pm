use 5.006;    # our
use strict;
use warnings;

package Gentoo::Atom::Scraper::Versions;

our $VERSION = '0.001000';

# ABSTRACT: Extract versions from a portage repo

# AUTHORITY

use Gentoo::Atom::Scraper::Packages;
use Path::Tiny qw( path );

sub scrape {
    my ( $self, $repository ) = @_;
    my (@out);
    $self->foreach(
        $repository,
        sub {
            push @out, "$_[0]/$_[1]-$_[2]";
        }
    );
    return [ sort @out ];
}

sub scrape_package_full {
    my ( $self, $repository, $category, $package ) = @_;
    my (@out);
    $self->foreach_package(
        $repository => $category => $package => sub {
            push @out, "$category/$package-$_[0]";
        }
    );
    return [ sort @out ];
}

sub scrape_package_short {
    my ( $self, $repository, $category, $package ) = @_;
    my (@out);
    $self->foreach_package(
        $repository => $category => $package => sub {
            push @out, $_[0];
        }
    );
    return [ sort @out ];
}

sub foreach {
    my ( $self, $repository, $callback ) = @_;
    Gentoo::Atom::Scraper::Packages->foreach(
        $repository => sub {
            my ( $category, $package ) = @_;
            $self->foreach_package(
                $repository => $category => $package => sub {
                    $callback->( $category, $package, $_[0] );
                }
            );
        }
    );
}

sub foreach_package {
    my ( $self, $repository, $category, $package, $callback ) = @_;
    opendir my $dfh,
      path( $repository, $category, $package )->absolute->stringify;
    while ( my $nodename = readdir $dfh ) {
        next if $nodename eq '.' or $nodename eq '..';
        next unless $nodename =~ /\.ebuild$/;
        next
          unless path( $repository, $category, $package, $nodename )->is_file;
        if ( $nodename =~ /\A\Q$package\E-(.+)\.ebuild\z/ ) {
            $callback->("$1");
        }
    }
}
1;

