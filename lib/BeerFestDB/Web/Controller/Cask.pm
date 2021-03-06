#
# This file is part of BeerFestDB, a beer festival product management
# system.
# 
# Copyright (C) 2010 Tim F. Rayner
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
# $Id$

package BeerFestDB::Web::Controller::Cask;
use Moose;
use namespace::autoclean;

use JSON::MaybeXS;

BEGIN {extends 'BeerFestDB::Web::Controller'; }

with 'BeerFestDB::DipMunger';

use Storable qw(dclone);

=head1 NAME

BeerFestDB::Web::Controller::Cask - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut

sub BUILD {

    my ( $self, $params ) = @_;

    $self->model_view_map({
        cask_id           => 'cask_id',
        cask_management_id => 'cask_management_id', # FIXME try removing this at some point
        festival_id       => {
            cask_management_id => 'festival_id'
        },
        festival_name     => {
            cask_management_id => {
                festival_id => 'name',
            },
        },
        distributor_id    => {
            cask_management_id => 'distributor_company_id',
        },
        order_batch_id    => {
            cask_management_id => {
                product_order_id => 'order_batch_id',
            },
        },
        order_batch_name    => {
            cask_management_id => {
                product_order_id => {
                    order_batch_id => 'description',
                },
            },
        },
        container_size_id => {
            cask_management_id => 'container_size_id',
        },
        bar_id            => {
            cask_management_id => 'bar_id',
        },
        stillage_location_id => {
            cask_management_id => 'stillage_location_id',
        },
        currency_id       => {
            cask_management_id => 'currency_id',
        },
        price             => {
            cask_management_id => 'price',
        },
        gyle_id           => 'gyle_id',
        product_id        => {
            gyle_id  => {
                festival_product_id => 'product_id',
            },            
        },
        product_name      => {
            gyle_id  => {
                festival_product_id => {
                    product_id  => 'name',
                },
            },            
        },
        company_id        => {
            gyle_id  => 'company_id',
        },
        company_name        => {
            gyle_id  => {
                company_id  => 'name',
            },
        },
        stillage_bay      => {
            cask_management_id => 'stillage_bay',
        },
        bay_position_id   => {
            cask_management_id => 'bay_position_id',
        },
        stillage_x        => {
            cask_management_id => 'stillage_x_location',
        },
        stillage_y        => {
            cask_management_id => 'stillage_y_location',
        },
        stillage_z        => {
            cask_management_id => 'stillage_z_location',
        },
        comment           => 'comment',
        ext_reference     => 'external_reference',
        int_reference     => {
            cask_management_id => 'internal_reference',
        },
        festival_ref      => {
            cask_management_id => 'cellar_reference',
        },
        is_vented         => 'is_vented',
        is_tapped         => 'is_tapped',
        is_ready          => 'is_ready',
        is_condemned      => 'is_condemned',
        is_sale_or_return => {
            cask_management_id => 'is_sale_or_return',
        },
    });
}

=head2 view

=cut

sub view : Local {

    my ( $self, $c, $id ) = @_;

    my $object = $c->model('DB::Cask')->find($id);

    unless ( $object ) {
        $c->flash->{error} = "Error: Cask not found.";
        $c->res->redirect( $c->uri_for('/default') );
        $c->detach();
    }

    $c->stash->{object} = $object;

    return;
}

=head2 load_form

=cut

sub load_form : Local {

    my ( $self, $c ) = @_;

    my $rs = $c->model('DB::Cask');

    $self->form_json_and_detach( $c, $rs, 'cask_id' );
}

=head2 list

=cut

sub list : Local {

    my ( $self, $c, $festival_id, $category_id ) = @_;

    my ( $rs, $festival );
    if ( defined $festival_id ) {
        $festival = $c->model( 'DB::Festival' )->find({festival_id => $festival_id});
        unless ( $festival ) {
            $c->stash->{error} = qq{Festival ID "$festival_id" not found.};
            $c->res->redirect( $c->uri_for('/default') );
            $c->detach();
        }
        $rs = $festival->search_related('cask_managements')
                       ->search_related('casks',
                                        { 'product_id.product_category_id' => $category_id },
                                        {
                                            join     => {
                                                gyle_id => {
                                                    festival_product_id => {
                                                        product_id => 'product_category_id' } } },
                                        });
    }
    else {
        die('Error: festival_id not defined.');
    }

    $self->generate_json_and_detach( $c, $rs );
}

=head2 grid

=cut

sub grid : Local {

    my ( $self, $c, $festival_id, $category_id ) = @_;

    my $festival = $c->model('DB::Festival')->find($festival_id);
    unless ( $festival ) {
        $c->flash->{error} = qq{Festival ID "$festival_id" not found.};
        $c->res->redirect( $c->uri_for('/default') );
        $c->detach();        
    }
    $c->stash->{festival} = $festival;

    my $category = $c->model('DB::ProductCategory')->find($category_id);
    unless ( $category ) {
        $c->flash->{error} = qq{Product category ID "$category_id" not found.};
        $c->res->redirect( $c->uri_for('/default') );
        $c->detach();        
    }
    $c->stash->{category} = $category;

    $self->get_default_currency( $c );
}

=head2 list_by_stillage

=cut

sub list_by_stillage : Local {

    my ( $self, $c, $id ) = @_;

    my $rs = $c->model( 'DB::Cask' )
        ->search({ 'cask_management_id.stillage_location_id' => $id },
                 { join => 'cask_management_id' });

    $self->generate_json_and_detach( $c, $rs );
}

=head2 list_by_festival_product

=cut

sub list_by_festival_product : Local {

    my ( $self, $c, $id ) = @_;

    my $fp = $c->model( 'DB::FestivalProduct' )
               ->find({ festival_product_id => $id });

    my $rs = $c->model( 'DB::Cask' )
               ->search({
                   'cask_management_id.festival_id' => $fp->get_column('festival_id'),
                   'gyle_id.festival_product_id' => $fp->get_column('festival_product_id'),
               }, { join => [ { gyle_id => 'festival_product_id' },
                              { cask_management_id => 'festival_id' } ] });

    $self->generate_json_and_detach( $c, $rs );
}

=head2 list_dips

=cut

sub list_dips : Local {

    my ( $self, $c, $cask_id ) = @_;

    my $cask = $c->model('DB::Cask')->find({ cask_id => $cask_id });

    unless ( $cask ) {
        $c->stash->{error} = 'Cask not found.';
        $c->res->redirect( $c->uri_for('/default') );
        $c->detach();
    }

    my $dips;
    eval {
        $dips = $self->munge_dips( $cask );
    };
    if ( $@ ) {
        $self->detach_with_txn_failure( $c, $@ );
    }

    $c->stash->{ 'objects' } = $dips;
    $c->stash->{ 'success' } = JSON->true();

    $c->forward( 'View::JSON' );
}

sub _extract_caskman_terms : Private {

    my ( $self, $rec, $mv_map ) = @_;

    my $newrec = dclone($rec);

    my ( %caskmanrec, %caskman_mvmap );

    my @deleted_keys;
    while ( my ( $key, $value ) = each %$rec ) {
        if ( ref $mv_map->{ $key } eq 'HASH' ) {
            if ( my $caskmankey = $mv_map->{ $key }->{ 'cask_management_id' } ) {
                $caskmanrec{ $key }    = $value;
                $caskman_mvmap{ $key } = $caskmankey;
                push @deleted_keys, $key;
            }
        }
    }

    foreach my $key ( @deleted_keys ) {
        delete $newrec->{ $key };
    }

    return( $newrec, \%caskmanrec, \%caskman_mvmap );
}

sub build_database_object : Private {

    my ( $self, $rec, $c, $rs, $mv_map, $no_update ) = @_;

    $mv_map ||= $self->model_view_map();

    # If any mv_map keys point to hashes containing cask_management_id
    # as a key, build that caskman object; then build a cask pointing
    # to that caskman via its ID.
    my $caskman_refs;
    if ( ref $mv_map eq 'HASH' ) {
        foreach my $subref ( values %$mv_map ) {
            if ( ref $subref eq 'HASH' ) {
                $caskman_refs += scalar grep { $_ eq 'cask_management_id' } keys %$subref;
            }
        }
    }
    if ( $caskman_refs && ! $rec->{ 'cask_management_id' } ) {
        $c->log->debug("Attempting to create cask_management object.");
        my ($caskman, $caskman_rec, $caskman_mvmap);
        ( $rec, $caskman_rec, $caskman_mvmap ) = $self->_extract_caskman_terms( $rec, $mv_map );
        $caskman = $self->build_database_object( $caskman_rec, $c,
                                                 $c->model( 'DB::CaskManagement' ),
                                                 $caskman_mvmap, $no_update );
        $rec->{ 'cask_management_id' } = $caskman->cask_management_id();
    }

    $self->next::method( $rec, $c, $rs, $mv_map, $no_update );
}

=head2 submit

=cut

sub submit : Local {

    my ( $self, $c ) = @_;

    my $rs = $c->model( 'DB::Cask' );

    $self->write_to_resultset( $c, $rs );
}

=head2 delete

=cut

sub delete : Local {

    my ( $self, $c ) = @_;

    my $rs = $c->model( 'DB::Cask' );

    $self->delete_from_resultset( $c, $rs );
}

sub delete_database_object : Private {
    my ( $self, $c, $rec ) = @_;

    # Ensure that cask deletion doesn't result in orphaned cask_management rows.
    if ( $rec->result_source->source_name() eq 'Cask' ) {
        my $caskman = $rec->cask_management_id;
        $self->next::method( $c, $rec );
        if ( ! $caskman->product_order_id ) {
            $self->next::method( $c, $caskman );
        }
    }
}

=head2 delete_from_stillage

=cut

sub delete_from_stillage : Local {

    my ( $self, $c ) = @_;

    my $rs = $c->model( 'DB::Cask' );

    my $data = $self->decode_json_changes($c);

    eval {
        $rs->result_source()->schema()->txn_do(
            sub {
                foreach my $id ( @{ $data } ) {
                    my $rec = $rs->find($id);
                    eval {
                        my $caskman = $rec->cask_management_id;
                        $caskman->set_column('stillage_location_id', undef);
                        $caskman->update();
                    };
                    if ($@) {
                        $self->raise_exception($c,
                                               "Unable to delete Cask with ID=$id from stillage\n");
                    }
                }
            }
        );
    };
    if ( $@ ) {
        $self->detach_with_txn_failure( $c, $rs, $@ );
    }

    $c->forward( 'View::JSON' );
}

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2010 by Tim F. Rayner

This library is released under version 3 of the GNU General Public
License (GPL).

=cut

__PACKAGE__->meta->make_immutable;

1;
