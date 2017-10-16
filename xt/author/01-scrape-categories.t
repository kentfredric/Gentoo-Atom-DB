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

my %found;
Gentoo::Atom::Scraper::Categories->foreach(
    $ENV{PORTDIR} || '/usr/portage',
    sub {
        $_[0] eq 'dev-perl' and $found{'dev-perl'}++;
        $_[0] eq 'virtual'  and $found{'virtual'}++;
        $_[0] eq 'profiles' and $found{'profiles'}++;
        $_[0] eq 'metadata' and $found{'metadata'}++;
    }
);
cmp_ok( scalar keys %found,
    '==', 2, "Found exactly all the looked for categories" );

done_testing;
