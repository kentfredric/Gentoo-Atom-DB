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
    $self->_schema->txn_do( sub { $self->_inner_sync } );
}

use constant TRACE => $ENV{TRACE_ENABLED};

sub _trace {
    my ( $self, $kind, $data ) = @_;
}

sub _inner_sync {
    my ($self) = @_;
    my $sync = $self->_Sync->new( { sync_start => scalar time } );
    $sync->insert;

    TRACE and $self->_trace( 'sync.id'    => $sync->sync_id );
    TRACE and $self->_trace( 'sync.start' => $sync->sync_start );

    local $self->{sync_id} = $sync->sync_id;

    my $sync_id = $sync->sync_id;
    my $repo    = $self->_repo;

    {
        my @categories;
        Gentoo::Atom::Scraper::Categories->foreach(
            $repo => sub { push @categories, $_[0] }, );

        TRACE and $self->_trace( 'categories.sync.count', scalar @categories );

        my %seen_categories = map { $_ => 0 } @categories;

        my (@all_categories) = $self->_Category->search(undef)->all;
        for my $category (@all_categories) {
            next unless exists $seen_categories{ $category->category_name };
            $seen_categories{ $category->category_name }++;
            $category->update( { sync_id => $sync_id } );
        }
        if (
            my (@new_categories) =
            grep { not $seen_categories{$_} } keys %seen_categories
          )
        {
            TRACE
              and $self->_trace(
                'categories.sync.new.count' => scalar @new_categories );
            TRACE
              and
              $self->_trace( 'categories.sync.new.names' => \@new_categories );
            $self->_Category->populate(
                [
                    [qw( category_name sync_id )],
                    map { [ $_, $sync_id ] } @new_categories
                ]
            );

        }
    }

    for my $category (
        $self->_Category->search( { sync_id => $self->_sync_id } )->all )
    {
        TRACE
          and $self->_trace( 'category.sync.name' => $category->category_name );

        my $category_id   = $category->category_id;
        my $category_name = $category->category_name;
        my (@package_names);
        Gentoo::Atom::Scraper::Packages->foreach_category(
            $repo => $category_name,
            sub {
                push @package_names, $_[0];
            }
        );
        TRACE
          and $self->_trace(
            'category.sync.packages.count' => scalar @package_names );

        my (%seen_packages) = map { $_ => 0 } @package_names;

        my (@all_packages) =
          $self->_Package->search( { category_id => $category_id }, )->all;
        for my $package (@all_packages) {
            next unless exists $seen_packages{ $package->package_name };
            $seen_packages{ $package->package_name }++;
            $package->update( { sync_id => $sync_id } );
        }

        my (@new_packages) =
          grep { not $seen_packages{$_} } keys %seen_packages;
        if (@new_packages) {
            $self->_Package->populate(
                [
                    [qw( package_name category_id sync_id )],
                    map { [ $_, $category_id, $sync_id ] } @new_packages
                ]
            );
        }

        my (@results) = $self->_Package->search(
            { sync_id => $self->_sync_id, category_id => $category_id } )->all;

        for my $package (@results) {
            $self->_sync_package( $category_id, $category_name,
                $package->package_id, $package->package_name );
        }

    }

    $sync->update( { sync_stop => scalar time } );
    TRACE and $self->_trace( 'sync.stop' => $sync->sync_stop );
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
