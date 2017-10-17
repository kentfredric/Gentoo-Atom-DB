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
        '_repo'   => $repo,
        '_schema' => $schema,
    }, $package;
}
sub _schema { $_[0]->{_schema} }
sub _repo   { $_[0]->{_repo} }

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
    my $schema = $self->_schema;
    my $sync = $schema->resultset('Sync')->new( { sync_start => scalar time } );
    $sync->insert;
    my $sync_id = $sync->sync_id;

    TRACE and $self->_trace( 'sync.id'    => $sync_id );
    TRACE and $self->_trace( 'sync.start' => $sync->sync_start );

    my $repo = $self->_repo;

    # Category List Synchronization
    {
        my @categories;
        Gentoo::Atom::Scraper::Categories->foreach(
            $repo => sub { push @categories, $_[0] }, );

        TRACE and $self->_trace( 'categories.sync.count', scalar @categories );

        my %seen_categories = map { $_ => 0 } @categories;

        my (@all_categories) =
          $schema->resultset('Category')->search(undef)->all;
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
            $schema->resultset('Category')->populate(
                [
                    [qw( category_name sync_id )],
                    map { [ $_, $sync_id ] } @new_categories
                ]
            );

        }
    }

    # Synchronization of Packages in Categories
    for my $category (
        $schema->resultset('Category')->search( { 'sync_id' => $sync_id } )
        ->all )
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
          $schema->resultset('Package')
          ->search( { category_id => $category_id }, )->all;
        for my $package (@all_packages) {
            next unless exists $seen_packages{ $package->package_name };
            $seen_packages{ $package->package_name }++;
            $package->update( { sync_id => $sync_id } );
        }

        my (@new_packages) =
          grep { not $seen_packages{$_} } keys %seen_packages;
        if (@new_packages) {
            $schema->resultset('Package')->populate(
                [
                    [qw( package_name category_id sync_id )],
                    map { [ $_, $category_id, $sync_id ] } @new_packages
                ]
            );
        }

        for my $package ( $schema->resultset('Package')
            ->search( { sync_id => $sync_id, category_id => $category_id } )
            ->all )
        {
            my $package_id   = $package->package_id;
            my $package_name = $package->package_name;
            my (@versions);
            Gentoo::Atom::Scraper::Versions->foreach_package( $repo,
                $category_name, $package_name, sub { push @versions, $_[0] } );

            my (%seen_versions) = map { $_ => 0 } @versions;

            my (@all_versions) = $schema->resultset('Version')->search(
                {
                    category_id => $category_id,
                    package_id  => $package_id,
                },
            )->all;

            for my $version (@all_versions) {
                next unless exists $seen_versions{ $version->version_string };
                $seen_versions{ $version->version_string }++;
                $version->update( { sync_id => $sync_id } );
            }

            my (@new_versions) =
              grep { not $seen_versions{$_} } keys %seen_versions;
            if (@new_versions) {
                $schema->resultset('Version')->populate(
                    [
                        [qw( version_string package_id category_id sync_id )],
                        map { [ $_, $package_id, $category_id, $sync_id ] }
                          @new_versions
                    ]
                );
            }
        }
    }
    $sync->update( { sync_stop => scalar time } );
    TRACE and $self->_trace( 'sync.stop' => $sync->sync_stop );
}
1;
