#!perl
use strict;
use warnings;

BEGIN { $ENV{TRACE_ENABLED} = 1 }

use lib 'lib';
use Gentoo::Atom::DB::Syncer;
use Gentoo::Atom::DB::Schema;
use constant PORTDIR => ( $ENV{PORTDIR} || '/usr/portage' );

my $dbh =
  Gentoo::Atom::DB::Schema->connect('dbi:SQLite:dbname=./tmp/db.sqlite');

  {

    package DebugSyncer;
    our @ISA = ('Gentoo::Atom::DB::Syncer');

    use Data::Dump qw(pp);

    sub _trace {
        my $self = shift;
        warn "$_[0] => " . pp($_[1]) . "\n";
    }
}

$dbh->storage->_get_dbh->do('PRAGMA synchronous = OFF');
my $sync = DebugSyncer->new( PORTDIR, $dbh );
$sync->sync;
