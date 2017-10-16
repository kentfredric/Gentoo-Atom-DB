
use strict;
use warnings;

use Test::More;
use constant PORTDIR => ( $ENV{PORTDIR} || '/usr/portage' );
use Gentoo::Atom::Scraper::Versions;

my (@versions) =
  @{ Gentoo::Atom::Scraper::Versions->scrape_package_full( PORTDIR, 'dev-lang',
        'perl' )
  };

my $need_diag;
cmp_ok( scalar @versions, '>', 0, "More than 0 versions of dev-lang/perl" )
  || $need_diag++;
cmp_ok( ( scalar grep /\Adev-lang\/perl-5\./, @versions ),
    '>', 0, "More than 0 versions of perl 5.xx" )
  || $need_diag++;
note explain \@versions if $need_diag;

my %found;
my $its;
Gentoo::Atom::Scraper::Versions->foreach(
    PORTDIR,
    sub {
        $its++;
    }
);
note "$its versions found";

done_testing;

