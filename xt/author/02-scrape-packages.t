
use strict;
use warnings;

use Test::More;
use constant PORTDIR => ( $ENV{PORTDIR} || '/usr/portage' );
use Gentoo::Atom::Scraper::Packages;

my %category =
  map { $_ => 1 } @{ Gentoo::Atom::Scraper::Packages->scrape_category_full(
        PORTDIR, 'dev-lang'
    )
  };

ok( exists $category{'dev-lang/perl'}, 'dev-lang/perl exists' );
ok( exists $category{'dev-lang/ruby'}, 'dev-lang/ruby exists' );
ok(
    !exists $category{'dev-lang/metadata.xml'},
    'dev-lang/metadata.xml is not a package'
);

my %found;
my $its;
Gentoo::Atom::Scraper::Packages->foreach(
    PORTDIR,
    sub {
        $found{'dev-lang/perl'}++ if $_[0] eq 'dev-lang' and $_[1] eq 'perl';
        $found{'dev-lang/ruby'}++ if $_[0] eq 'dev-lang' and $_[1] eq 'ruby';
        $its++;
    }
);
note "$its packages found";
cmp_ok( scalar keys %found, '==', 2, "Found 2 matching packages" );

done_testing;

