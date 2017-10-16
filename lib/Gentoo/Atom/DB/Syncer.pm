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
    $sync->sync_stop( scalar time );
    $sync->update;
}

sub _update_or_create_category {
    my ( $self, $category_name ) = @_;
    my $result =
      $self->_Category->single( { category_name => $category_name } );
    if ($result) {
        $result->sync_id( $self->_sync_id );
        $result->update;
        return $result;
    }
    $result = $self->_Category->new(
        { category_name => $category_name, sync_id => $self->_sync_id } );
    $result->insert;
    return $result;
}

sub _sync_categories {
    my ($self)    = @_;
    my $_Category = $self->_Category;
    my $sync_id   = $self->_sync_id;
    Gentoo::Atom::Scraper::Categories->foreach(
        $self->_repo => sub {
            $self->_sync_category( $self->_update_or_create_category( $_[0] ) );
        },
    );
}

sub _update_or_create_package {
    my ( $self, $category_id, $package_name ) = @_;
    my $result = $self->_Package->single(
        { category_id => $category_id, package_name => $package_name } );
    if ($result) {
        $result->sync_id( $self->_sync_id );
        $result->update;
        return $result;
    }
    $result = $self->_Package->new(
        {
            category_id  => $category_id,
            package_name => $package_name,
            sync_id      => $self->_sync_id
        }
    );
    $result->insert;
    return $result;
}

sub _sync_category {
    my ( $self, $category ) = @_;
    my $sync_id  = $self->_sync_id;
    my $_Package = $self->_Package;
    Gentoo::Atom::Scraper::Packages->foreach_category(
        $self->_repo => $category->category_name,
        sub {
            my ($package_name) = @_;
            $self->_sync_package(
                $category,
                $self->_update_or_create_package(
                    $category->category_id, $package_name
                )
            );
        }
    );
}

sub _update_or_create_version {
   my ( $self, $category_id, $package_id, $version_string ) = @_;
   my $result = $self->_Version->single({ category_id => $category_id, package_id => $package_id, version_string => $version_string });
   if ( $result ) { 
     $result->sync_id( $self->_sync_id );
     $result->update;
     return $result;
   }
   $result = $self->_Version->new({
      category_id => $category_id, 
      package_id => $package_id,
      version_string => $version_string,
      sync_id => $self->_sync_id,
    });
  $result->insert;
  return $result;
}

sub _sync_package {
    my ( $self, $category, $package ) = @_;
    my $sync_id  = $self->_sync_id;
    my $_Version = $self->_Version;
    Gentoo::Atom::Scraper::Versions->foreach_package(
        $self->_repo,
        $category->category_name,
        $package->package_name,
        sub {
            my ($version) = @_;
            my $version_record = $self->_update_or_create_version( $category->category_id, $package->package_id, 
              $version );
        },
    );
}

1;

