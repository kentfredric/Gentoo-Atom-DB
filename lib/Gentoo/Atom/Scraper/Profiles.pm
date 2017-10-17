use 5.006;  # our
use strict;
use warnings;

package Gentoo::Atom::Scraper::Profiles;

our $VERSION = '0.001000';

# ABSTRACT: Profile scraper

# AUTHORITY

use Path::Tiny qw( path );

sub scrape {
    my ( $self, $repo ) = @_;
    my (@out);
    $self->foreach( $repo, sub { push @out, $_[0] } );
    return [ sort { $a->{profile_name} cmp $b->{profile_name} } @out ];
}

sub foreach {
    my ( $self, $repo, $callback ) = @_;
    my $path = path($repo);
    $path->exists or die "$path should be a repository path";
    my $archfile = $path->child( 'profiles', 'profiles.desc' );
    $archfile->is_file or die "$archfile should exist and be an arch listing";
    my $fh = $archfile->openr_raw;
    
    my (%seen_profiles);

    while ( my $line = <$fh> ) {
        chomp $line;
        $line =~ s/\s*#.*\z//;
        next if $line =~ /\A\s*\z/;
        my ( $archname, $profilepath, $status, @rest ) = split /\s+/, $line;
        my $ppath = path($repo,'profiles', $profilepath )->absolute;
        if ( not $ppath->is_dir  ) {
          warn "$ppath is not valid profile path";
          next;
        }
        my (@parents) = _profile_getparents( $repo, $profilepath );
        exists $seen_profiles{$_} or $seen_profiles{$_} = 0 for @parents;
        $seen_profiles{$profilepath}++;
        $callback->({
            architecture_name => $archname, 
            profile_name => $profilepath,
            profile_status => $status,
            parent_profiles => \@parents,
        });
    }
    while(grep { !$seen_profiles{$_} } keys %seen_profiles ) {
      my $unseen;
      for my $key ( keys %seen_profiles ) {
        next if $seen_profiles{$key};
        $unseen = $key;
        last;
      }
      my (@parents) = _profile_getparents($repo, $unseen );
      exists $seen_profiles{$_} or $seen_profiles{$_} = 0 for @parents;
      $seen_profiles{$unseen}++;
      $callback->({
            profile_name => $unseen,
            parent_profiles => \@parents,
      });
    }
}

sub _profile_getparents {
  my ( $repo, $profile ) = @_;
  my $ppath = path($repo,'profiles', $profile, 'parent' )->absolute;
  return () unless $ppath->is_file;
  return map { 
    path( $repo, 'profiles', $profile, $_ )->absolute('.')->realpath->relative(path($repo, 'profiles'))->stringify; 
  } $ppath->lines_raw({ chomp => 1 });
}

1;

