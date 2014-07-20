use utf8;
package BeerFestDB::ORM::Role;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

BeerFestDB::ORM::Role

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<role>

=cut

__PACKAGE__->table("role");

=head1 ACCESSORS

=head2 role_id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 rolename

  data_type: 'varchar'
  is_nullable: 0
  size: 255

=cut

__PACKAGE__->add_columns(
  "role_id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "rolename",
  { data_type => "varchar", is_nullable => 0, size => 255 },
);

=head1 PRIMARY KEY

=over 4

=item * L</role_id>

=back

=cut

__PACKAGE__->set_primary_key("role_id");

=head1 UNIQUE CONSTRAINTS

=head2 C<rolename>

=over 4

=item * L</rolename>

=back

=cut

__PACKAGE__->add_unique_constraint("rolename", ["rolename"]);

=head1 RELATIONS

=head2 category_auths

Type: has_many

Related object: L<BeerFestDB::ORM::CategoryAuth>

=cut

__PACKAGE__->has_many(
  "category_auths",
  "BeerFestDB::ORM::CategoryAuth",
  { "foreign.role_id" => "self.role_id" },
  undef,
);

=head2 user_roles

Type: has_many

Related object: L<BeerFestDB::ORM::UserRole>

=cut

__PACKAGE__->has_many(
  "user_roles",
  "BeerFestDB::ORM::UserRole",
  { "foreign.role_id" => "self.role_id" },
  undef,
);


# Created by DBIx::Class::Schema::Loader v0.07039 @ 2014-07-20 17:33:21
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:RKUfDd8LlNhkjH3ipvNpsw


# Many-to-many relationships are not yet autogenerated by
# DBIx::Class::Schema::Loader. We add them here:
__PACKAGE__->many_to_many(
    "users" => "user_roles", "user_id"
);
__PACKAGE__->many_to_many(
    "categories" => "category_auths", "product_category_id"
);

1;
