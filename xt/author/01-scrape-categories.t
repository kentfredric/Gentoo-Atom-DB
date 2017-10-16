use strict;
use warnings;

use Test::More;
use Gentoo::Atom::Scraper::Categories;

my (%scrape) = map { $_ => 1 } @{ Gentoo::Atom::Scraper::Categories->scrape(
        $ENV{PORTDIR} || '/usr/portage'
    )
};

ok( exists $scrape{virtual},     "category 'virtual' scraped" );
ok( exists $scrape{'dev-perl'},  "category 'dev-perl' scraped" );
ok( !exists $scrape{'profiles'}, "profiles is not a category" );
ok( !exists $scrape{'metadata'}, "metadata is not a category" );

done_testing;
