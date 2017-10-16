use 5.006;    # our
use strict;
use warnings;

package Gentoo::Atom::DB::Syncer;

our $VERSION = '0.001000';

# ABSTRACT: Sync FS state with a database

# AUTHORITY

use Gentoo::Atom::Scraper::Categories;
use Gentoo::Atom::Scraper::Packages;
use Gentoo::Atom::Scraper::Versions;

sub new {
    my ( $package, $repo, $schema ) = @_;
    bless {
        '_repo'     => $repo,
        '_schema'   => $schema,
        '_Sync'     => $schema->resultset('Sync'),
        '_Category' => $schema->resultset('Category'),
        '_Package'  => $schema->resultset('Package'),
        '_Version'  => $schema->resultset('Version'),
    }, $package;
}
sub _schema   { $_[0]->{_schema} }
sub _repo     { $_[0]->{_repo} }
sub _Sync     { $_[0]->{_Sync} }
sub _Category { $_[0]->{_Category} }
sub _Package  { $_[0]->{_Package} }
sub _Version  { $_[0]->{_Version} }
sub _sync_id  { $_[0]->{sync_id} }

sub sync {
    my ($self) = @_;

    $self->_schema->txn_do(
        sub {
            $self->_in_sync(
                sub {
                    $self->_sync_categories;
                }
            );
        }
    );
}

sub _in_sync {
    my ( $self, $cb ) = @_;
    my $sync = $_[0]->_Sync->new( { sync_start => scalar time } );
    $sync->insert;
    local $self->{sync_id} = $sync->sync_id;
    $cb->();
    $sync->update( { sync_start => scalar time } );
}

sub _sync_categories {
    my ($self) = @_;
    my (@categories);

    Gentoo::Atom::Scraper::Categories->foreach(
        $self->_repo => sub {
            push @categories, $_[0];
        }
    );

    $self->_update_categories( \@categories );

    for my $category (
        $self->_Category->search( { sync_id => $self->_sync_id } )->all )
    {
        $self->_sync_category( $category->category_id,
            $category->category_name );
    }
}

sub _update_categories {
    my ( $self, $categories ) = @_;
    my $sync_id = $self->_sync_id;
    my (@results) =
      $self->_Category->search( { category_name => { '-in' => $categories } } )
      ->all;

    my (%seen) = map { $_ => 0 } @{$categories};
    for my $item (@results) {
        $seen{ $item->category_name }++;
        $item->update( { sync_id => $sync_id } );
    }
    my (@new) = grep { not $seen{$_} } keys %seen;
    if (@new) {
        $self->_Category->populate(
            [ [qw( category_name sync_id )], map { [ $_, $sync_id ] } @new ] );
    }
}

sub _sync_category {
    my ( $self, $category_id, $category_name ) = @_;
    my (@package_names);
    Gentoo::Atom::Scraper::Packages->foreach_category(
        $self->_repo => $category_name,
        sub {
            push @package_names, $_[0];
        }
    );
    $self->_update_packages( $category_id, $category_name, \@package_names );

    my (@results) = $self->_Package->search(
        { sync_id => $self->_sync_id, category_id => $category_id } )->all;

    for my $package (@results) {
        $self->_sync_package( $category_id, $category_name,
            $package->package_id, $package->package_name );
    }
}

sub _update_packages {
    my ( $self, $category_id, $category_name, $packages ) = @_;
    my $sync_id = $self->_sync_id;
    my (%seen) = map { $_ => 0 } @{$packages};

    while ( @{$packages} ) {

        # beyond 10 or so the returns diminsh too slowly
        my (@subset) = splice @{$packages}, 0, 20, ();

        my (@results) = $self->_Package->search(
            {
                category_id  => $category_id,
                package_name => { '-in' => \@subset }
            },
        )->all;

        for my $item (@results) {
            $seen{ $item->package_name }++;
            $item->update( { sync_id => $sync_id } );
        }
    }
    my (@new) = grep { not $seen{$_} } keys %seen;
    if (@new) {
        $self->_Package->populate(
            [
                [qw( package_name category_id sync_id )],
                map { [ $_, $category_id, $sync_id ] } @new
            ]
        );
    }
}

sub _sync_package {
    my ( $self, $category_id, $category_name, $package_id, $package_name ) = @_;
    my (@versions);
    Gentoo::Atom::Scraper::Versions->foreach_package( $self->_repo,
        $category_name, $package_name, sub { push @versions, $_[0] } );

    $self->_update_versions(
        $category_id,  $category_name, $package_id,
        $package_name, \@versions
    );

}

sub _update_versions {
    my (
        $self,       $category_id,  $category_name,
        $package_id, $package_name, $versions
    ) = @_;
    my $sync_id = $self->_sync_id;
    my (%seen) = map { $_ => 0 } @{$versions};

    while ( @{$versions} ) {

        # beyond 10 or so the returns diminsh too slowly
        my (@subset) = splice @{$versions}, 0, 20, ();

        my (@results) = $self->_Version->search(
            {
                category_id    => $category_id,
                package_id     => $package_id,
                version_string => { '-in' => \@subset }
            },
        )->all;

        for my $item (@results) {
            $seen{ $item->version_string }++;
            $item->update( { sync_id => $sync_id } );
        }
    }
    my (@new) = grep { not $seen{$_} } keys %seen;
    if (@new) {
        $self->_Version->populate(
            [
                [qw( version_string package_id category_id sync_id )],
                map { [ $_, $package_id, $category_id, $sync_id ] } @new
            ]
        );
    }
}

1;
