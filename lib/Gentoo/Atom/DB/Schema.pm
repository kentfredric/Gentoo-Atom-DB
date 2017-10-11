use 5.006;    # our
use strict;
use warnings;

package Gentoo::Atom::DB::Schema;

our $VERSION = '0.001000';

use DBIx::Class::Core   ();
use DBIx::Class::Schema ();

our @ISA = ('DBIx::Class::Schema');

sub schema_version { 1 }

my $is_sync;

BEGIN {

    $is_sync = sub {
        $_[0]->add_columns(
            'sync_id' => {
                data_type      => 'integer',
                is_nullable    => 1,
                is_numeric     => 1,
                is_foreign_key => 1,
            },
        );
        $_[0]->belongs_to(
            'sync' => 'Gentoo::Atom::DB::Schema::Result::Sync',
            { 'foreign.sync_id' => 'self.sync_id', }
        );
    };
}

for my $class (
    qw( Category Package Version SupportLevel Architecture VersionSupport Profile Mask
    MaskImpact Trait NoteKind Note TraitApplies NoteApplies Sync
    )
  )
{
    my $comp_class = "Gentoo::Atom::DB::Schema::Result::$class";
    __PACKAGE__->register_class(
        ( $comp_class->can('source_name') && $comp_class->source_name )
          || $class,
        "Gentoo::Atom::DB::Schema::Result::$class"
    );
}

BEGIN {    # Sync
    package    # hide
      Gentoo::Atom::DB::Schema::Result::Sync;

    our @ISA = ('DBIx::Class::Core');
    __PACKAGE__->table('sync');
    __PACKAGE__->add_columns(
        'sync_id' => {
            data_type         => 'integer',
            is_nullable       => 0,
            is_auto_increment => 1,
            is_numeric        => 1,
        },
        'sync_start' => {
            data_type   => 'text',
            is_nullable => 0,
        },
        'sync_stop' => {
            data_type   => 'text',
            is_nullable => 1,
        },
    );
    __PACKAGE__->set_primary_key('sync_id');
    __PACKAGE__->add_unique_constraint( ['sync_start'] );
}

BEGIN {    # Category
    package    # hide
      Gentoo::Atom::DB::Schema::Result::Category;

    our @ISA = ('DBIx::Class::Core');

    __PACKAGE__->table('category');
    __PACKAGE__->add_columns(
        'category_id' => {
            data_type         => 'integer',
            is_nullable       => 0,
            is_auto_increment => 1,
            is_numeric        => 1,
        },
        'category_name' => { data_type => 'text', is_nullable => 0, },

    );
    __PACKAGE__->set_primary_key('category_id');
    __PACKAGE__->add_unique_constraint( ['category_name'] );
    __PACKAGE__->has_many(
        'packages' => 'Gentoo::Atom::DB::Schema::Result::Package',
        {
            'foreign.category_id' => 'self.category_id',
        }
    );
    $is_sync->(__PACKAGE__);

}

BEGIN {    # Package
    package    # hide
      Gentoo::Atom::DB::Schema::Result::Package;

    our @ISA = ('DBIx::Class::Core');

    __PACKAGE__->table('package');
    __PACKAGE__->add_columns(
        'package_id' => {
            data_type         => 'integer',
            is_nullable       => 0,
            is_auto_increment => 1,
            is_numeric        => 1,
        },
        'package_name' => { data_type => 'text', is_nullable => 0, },
        'category_id'  => {
            data_type      => 'integer',
            is_nullable    => 0,
            is_numeric     => 1,
            is_foreign_key => 1,
        },
    );
    __PACKAGE__->set_primary_key('package_id');
    __PACKAGE__->add_unique_constraint( [ 'category_id', 'package_name' ] );
    __PACKAGE__->belongs_to(
        'category' => 'Gentoo::Atom::DB::Schema::Result::Category',
        {
            'foreign.category_id' => 'self.category_id',
        },
        {
            'on_delete' => 'CASCADE',
        }
    );
    __PACKAGE__->has_many(
        'versions' => 'Gentoo::Atom::DB::Schema::Result::Version',
        {
            'foreign.package_id' => 'self.package_id',
        }
    );
    $is_sync->(__PACKAGE__);
}

BEGIN {    # Version
    package    # hide
      Gentoo::Atom::DB::Schema::Result::Version;

    our @ISA = ('DBIx::Class::Core');

    __PACKAGE__->table('version');
    __PACKAGE__->add_columns(
        'version_id' => {
            data_type         => 'integer',
            is_nullable       => 0,
            is_auto_increment => 1,
            is_numeric        => 1,
        },
        'version_string' => { data_type => 'text', is_nullable => 0, },
        'category_id'    => {
            data_type      => 'integer',
            is_nullable    => 0,
            is_numeric     => 1,
            is_foreign_key => 1,
        },
        'package_id' => {
            data_type      => 'integer',
            is_nullable    => 0,
            is_numeric     => 1,
            is_foreign_key => 1,
        },

    );
    __PACKAGE__->set_primary_key('version_id');
    __PACKAGE__->add_unique_constraint(
        [ 'category_id', 'package_id', 'version_string' ] );

    __PACKAGE__->belongs_to(
        'category' => 'Gentoo::Atom::DB::Schema::Result::Category',
        {
            'foreign.category_id' => 'self.category_id',
        },
        {
            'on_update' => 'CASCADE',
            'on_delete' => 'CASCADE',
        }
    );
    __PACKAGE__->belongs_to(
        'package' => 'Gentoo::Atom::DB::Schema::Result::Package',
        {
            'foreign.category_id' => 'self.category_id',
            'foreign.package_id'  => 'self.package_id',
        },
        {
            'on_update' => 'CASCADE',
            'on_delete' => 'CASCADE',
        },
    );
    $is_sync->(__PACKAGE__);

}

BEGIN {    # SupportLevel
    package    # hide
      Gentoo::Atom::DB::Schema::Result::SupportLevel;

    our @ISA = ('DBIx::Class::Core');

    __PACKAGE__->table('support_level');
    __PACKAGE__->add_columns(
        'support_level_id' => {
            data_type         => 'integer',
            is_nullable       => 0,
            is_auto_increment => 1,
        },
        'support_level_name' => {
            data_type   => 'text',
            is_nullable => 0,
        },
    );
    __PACKAGE__->set_primary_key('support_level_id');
    __PACKAGE__->add_unique_constraint( ['support_level_name'] );
    $is_sync->(__PACKAGE__);

}

BEGIN {    # Architecture
    package    # hide
      Gentoo::Atom::DB::Schema::Result::Architecture;

    our @ISA = ('DBIx::Class::Core');

    __PACKAGE__->table('architecture');
    __PACKAGE__->add_columns(
        'architecture_id' => {
            data_type         => 'integer',
            is_nullable       => 0,
            is_auto_increment => 1,
        },
        'architecture_name' => {
            data_type   => 'text',
            is_nullable => 0,
        },
    );
    __PACKAGE__->set_primary_key('architecture_id');
    __PACKAGE__->add_unique_constraint( ['architecture_name'] );
    $is_sync->(__PACKAGE__);

}

BEGIN {    # VersionSupport
    package    # hide
      Gentoo::Atom::DB::Schema::Result::VersionSupport;

    our @ISA = ('DBIx::Class::Core');

    __PACKAGE__->table('version_support');
    __PACKAGE__->add_columns(
        'version_support_id' => {
            data_type         => 'integer',
            is_nullable       => 0,
            is_auto_increment => 1,
        },
        'architecture_id' => {
            data_type      => 'integer',
            is_nullable    => 0,
            is_numeric     => 1,
            is_foreign_key => 1,
        },
        'support_level_id' => {
            data_type      => 'integer',
            is_nullable    => 0,
            is_numeric     => 1,
            is_foreign_key => 1,
        },
    );
    __PACKAGE__->set_primary_key('version_support_id');
    __PACKAGE__->add_unique_constraint(
        [ 'architecture_id', 'support_level_id' ],
    );
    __PACKAGE__->belongs_to(
        'architecture' => 'Gentoo::Atom::DB::Schema::Result::Architecture',
        {
            'foreign.architecture_id' => 'self.architecture_id'
        },
    );
    __PACKAGE__->belongs_to(
        'support_level' => 'Gentoo::Atom::DB::Schema::Result::SupportLevel',
        {
            'foreign.support_level_id' => 'self.support_level_id'
        },
    );
    $is_sync->(__PACKAGE__);
}

BEGIN {    # Profile
    package    # hide
      Gentoo::Atom::DB::Schema::Result::Profile;

    our @ISA = ('DBIx::Class::Core');

    __PACKAGE__->table('profile');
    __PACKAGE__->add_columns(
        'profile_id' => {
            data_type         => 'integer',
            is_nullable       => 0,
            is_auto_increment => 1,
        },
        'profile_name' => {
            data_type   => 'text',
            is_nullable => 0,
        },
        'architecture_id' => {
            data_type      => 'integer',
            is_nullable    => 0,
            is_numeric     => 1,
            is_foreign_key => 1,
        },
        'parent_profile_id' => {
            data_type      => 'integer',
            is_nullable    => 1,
            is_numeric     => 1,
            is_foreign_key => 1,
        },
    );
    __PACKAGE__->set_primary_key('profile_id');
    __PACKAGE__->add_unique_constraint( ['profile_name'], );
    __PACKAGE__->belongs_to(
        'architecture' => 'Gentoo::Atom::DB::Schema::Result::Architecture',
        {
            'foreign.architecture_id' => 'self.architecture_id',
        }
    );
    __PACKAGE__->belongs_to(
        'parent_profile' => 'Gentoo::Atom::DB::Schema::Result::Profile',
        {
            'foreign.profile_id' => 'self.parent_profile_id',
        },
        {
            'join_type' => 'left',
        }
    );
    $is_sync->(__PACKAGE__);
}

BEGIN {    # Mask
    package    # hide
      Gentoo::Atom::DB::Schema::Result::Mask;

    our @ISA = ('DBIx::Class::Core');

    __PACKAGE__->table('mask');
    __PACKAGE__->add_columns(
        'mask_id' => {
            data_type         => 'integer',
            is_nullable       => 0,
            is_auto_increment => 1,
        },
        'mask_author' => {
            data_type   => 'text',
            is_nullable => 0,
        },
        'mask_datestamp' => {
            data_type   => 'text',
            is_nullable => 0,
        },
        'mask_content' => {
            data_type   => 'text',
            is_nullable => 0,
        },
        'mask_content_checksum' => {
            data_type   => 'text',
            is_nullable => 0,
        },
        'mask_atoms' => {
            data_type   => 'text',
            is_nullable => 0,
        }
    );
    __PACKAGE__->set_primary_key('mask_id');
    __PACKAGE__->add_unique_constraint( ['mask_content_checksum'], );
    $is_sync->(__PACKAGE__);
}

BEGIN {    # MaskImpact
    package    # hide
      Gentoo::Atom::DB::Schema::Result::MaskImpact;

    our @ISA = ('DBIx::Class::Core');

    __PACKAGE__->table('mask_impact');
    __PACKAGE__->add_columns(
        'mask_impact_id' => {
            data_type         => 'integer',
            is_nullable       => 0,
            is_auto_increment => 1,
        },
        'mask_id' => {
            data_type      => 'integer',
            is_nullable    => 0,
            is_numeric     => 1,
            is_foreign_key => 1,
        },
        'version_id' => {
            data_type      => 'integer',
            is_nullable    => 0,
            is_numeric     => 1,
            is_foreign_key => 1,
        },
    );
    __PACKAGE__->set_primary_key('mask_impact_id');
    __PACKAGE__->add_unique_constraint( [ 'mask_id', 'version_id' ], );

    __PACKAGE__->belongs_to(
        'version' => 'Gentoo::Atom::DB::Schema::Result::Version',
        {
            'foreign.version_id' => 'self.version_id',
        }
    );
    __PACKAGE__->belongs_to(
        'mask' => 'Gentoo::Atom::DB::Schema::Result::Mask',
        {
            'foreign.mask_id' => 'self.mask_id',
        }
    );
    $is_sync->(__PACKAGE__);
}

BEGIN {    # Trait
    package    # hide
      Gentoo::Atom::DB::Schema::Result::Trait;

    our @ISA = ('DBIx::Class::Core');

    __PACKAGE__->table('trait');
    __PACKAGE__->add_columns(
        'trait_id' => {
            data_type         => 'integer',
            is_nullable       => 0,
            is_auto_increment => 1,
        },
        'trait_name' => {
            data_type   => 'text',
            is_nullable => 0,
        }
    );
    __PACKAGE__->set_primary_key('trait_id');
    __PACKAGE__->add_unique_constraint( ['trait_name'] );
    $is_sync->(__PACKAGE__);
}

BEGIN {    # NoteKind
    package    # hide
      Gentoo::Atom::DB::Schema::Result::NoteKind;

    our @ISA = ('DBIx::Class::Core');

    __PACKAGE__->table('note_kind');
    __PACKAGE__->add_columns(
        'note_kind_id' => {
            data_type         => 'integer',
            is_nullable       => 0,
            is_auto_increment => 1,
        },
        'note_kind_name' => {
            data_type   => 'text',
            is_nullable => 0,
        }
    );
    __PACKAGE__->set_primary_key('note_kind_id');
    __PACKAGE__->add_unique_constraint( ['note_kind_name'] );
    $is_sync->(__PACKAGE__);
}

BEGIN {    # Note
    package    # hide
      Gentoo::Atom::DB::Schema::Result::Note;

    our @ISA = ('DBIx::Class::Core');

    __PACKAGE__->table('note');
    __PACKAGE__->add_columns(
        'note_id' => {
            data_type         => 'integer',
            is_nullable       => 0,
            is_auto_increment => 1,
        },
        'note_kind_id' => {
            data_type      => 'integer',
            is_nullable    => 0,
            is_foreign_key => 1,
        },
        'note_description' => {
            data_type   => 'text',
            is_nullable => 0,
        },
    );
    __PACKAGE__->set_primary_key('note_id');
    __PACKAGE__->belongs_to(
        'note_kind' => 'Gentoo::Atom::DB::Schema::Result::NoteKind',
        {
            'foreign.note_kind_id' => 'self.note_kind_id',
        }
    );
    $is_sync->(__PACKAGE__);
}

BEGIN {    # TraitApplies
    package    # hide
      Gentoo::Atom::DB::Schema::Result::TraitApplies;

    our @ISA = ('DBIx::Class::Core');

    __PACKAGE__->table('trait_applies');
    __PACKAGE__->add_columns(
        'trait_applies_id' => {
            data_type         => 'integer',
            is_nullable       => 0,
            is_auto_increment => 1,
        },
        'trait_id' => {
            data_type      => 'integer',
            is_nullable    => 0,
            is_foreign_key => 1,
        },
        'version_id' => {
            data_type      => 'integer',
            is_nullable    => 0,
            is_foreign_key => 1,
        },
    );
    __PACKAGE__->set_primary_key('trait_applies_id');
    __PACKAGE__->belongs_to(
        'trait' => 'Gentoo::Atom::DB::Schema::Result::Trait',
        {
            'foreign.trait_id' => 'self.trait_id',
        }
    );
    __PACKAGE__->belongs_to(
        'version' => 'Gentoo::Atom::DB::Schema::Result::Version',
        {
            'foreign.version_id' => 'self.version_id',
        },
    );
    $is_sync->(__PACKAGE__);
}

BEGIN {    # NoteApplies
    package    # hide
      Gentoo::Atom::DB::Schema::Result::NoteApplies;

    our @ISA = ('DBIx::Class::Core');

    __PACKAGE__->table('note_applies');
    __PACKAGE__->add_columns(
        'note_applies_id' => {
            data_type         => 'integer',
            is_nullable       => 0,
            is_auto_increment => 1,
        },
        'note_id' => {
            data_type      => 'integer',
            is_nullable    => 0,
            is_foreign_key => 1,
        },
        'version_id' => {
            data_type      => 'integer',
            is_nullable    => 0,
            is_foreign_key => 1,
        },
    );
    __PACKAGE__->set_primary_key('note_applies_id');
    __PACKAGE__->belongs_to(
        'note' => 'Gentoo::Atom::DB::Schema::Result::Note',
        {
            'foreign.note_id' => 'self.note_id',
        }
    );
    __PACKAGE__->belongs_to(
        'version' => 'Gentoo::Atom::DB::Schema::Result::Version',
        {
            'foreign.version_id' => 'self.version_id',
        },
    );
    $is_sync->(__PACKAGE__);
}
1;

=head1 SCHEMA

  Category <- Package <-\                 Trait <------ TraitApplies
            \------------\--- Version <--------------/
                                 ^                    \
                                 |        Note<------- NoteApplies
  SupportLevel<---               |          |
                   \             |          v
  Architecture <    \            |\       NoteKind
   ^            \    \           | \
   |             \- VersionSupport  |
  Profile<----                       |
     ^ |      \              MaskImpact
     \/        \             |
                \--Mask<-----/

Note:

In these rows, all keys are named C<"${tablename}_keyname">. C<< <othertablename> >>
is used as a prefix that indicates a foreign key is named C<"${othertablename}_keyname"> and refers to C<$othertable>
Except when its C<< <othertablename=keyname> >>, then the name is as-is and the FK is the =

  category [ id, name                                ]
  package  [ id, name,   <category> id               ]
  version  [ id, string, <category> id, <package> id ]

  architecture  [ id, name ]
  support_level [ id, name ]

  profile [ id, name,  <architecture> id, status, <profile=id> parent_profile ]
  mask    [ id, author, datestamp, content, content_checksum,           atoms ]

  version_support [ id, <version> id, <architecture> id, <support_level> id ]
  mask_impact     [ id, <version> id, <profile> id     , <mask> id          ]

  trait         [ id, name ]
  trait_applies [ id, <trait> id, <version> id ]

  note_kind     [ id, name ]
  note          [ id, note_kind <id>, description   ]
  note_applies  [ id, <note> id,      <version> id  ]
