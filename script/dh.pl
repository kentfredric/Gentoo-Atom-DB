#!perl
use strict;
use warnings;

{

    package My::DH;
    use Moose;
    extends "App::DH";
    use File::Spec;

    use lib 'lib';

    has '+connection_name' => (
        default => sub {
            'dbi:SQLite:dbname=./tmp/db.sqlite';
        }
    );

    has '+schema' => ( default => sub { 'Gentoo::Atom::DB::Schema' } );

    sub database {
        return [ 'GraphViz', 'SQLite', 'Diagram', 'PostgreSQL', 'MySQL', ];
    }

}

My::DH->new_with_options->run;

