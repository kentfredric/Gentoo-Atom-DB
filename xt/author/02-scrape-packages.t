
use strict;
use warnings;

use Test::More;
use Gentoo::Atom::Scraper::Packages;

my %category =
  map { $_ => 1 }
  @{ Gentoo::Atom::Scraper::Packages->scrape_category_full(
        ( $ENV{PORTDIR} || '/usr/portage' ), 'dev-lang' )
  };

ok( exists $category{'dev-lang/perl'}, 'dev-lang/perl exists' );
ok( exists $category{'dev-lang/ruby'}, 'dev-lang/ruby exists' );
ok(
    !exists $category{'dev-lang/metadata.xml'},
    'dev-lang/metadata.xml is not a package'
);

done_testing;

