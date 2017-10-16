
use strict;
use warnings;

use Test::More;
use Gentoo::Atom::DB::Syncer;
use Gentoo::Atom::DB::Schema;
use constant PORTDIR => ( $ENV{PORTDIR} || '/usr/portage' );

my $dbh =
  Gentoo::Atom::DB::Schema->connect('dbi:SQLite:dbname=./tmp/db.sqlite');

{

    package DebugSyncer;
    our @ISA = ('Gentoo::Atom::DB::Syncer');

    sub _update_or_create_category {
        my $self = shift;
        warn "- $_[0]\n";
        return $self->SUPER::_update_or_create_category(@_);
    }
}
my $sync = DebugSyncer->new( PORTDIR, $dbh );
$sync->sync;

my $rs = $dbh->resultset('Version')->search(
    {
        'category.category_name' => 'dev-perl',
    },
    {
        prefetch => [ 'package', 'category' ],
        order_by => [
            { '-asc' => 'category.category_name' },
            { '-asc' => 'package.package_name' },
            { '-asc' => 'version_string' }
        ],
    }
);

my $i = 0;
while ( my $item = $rs->next ) {
    note sprintf "%s/%s-%s", $item->category->category_name,
      $item->package->package_name, $item->version_string;
    $i++;
}
note "$i results";
done_testing;

