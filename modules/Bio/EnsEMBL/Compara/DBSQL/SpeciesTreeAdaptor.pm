=head1 LICENSE

Copyright [1999-2015] Wellcome Trust Sanger Institute and the EMBL-European Bioinformatics Institute
Copyright [2016-2017] EMBL-European Bioinformatics Institute

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

     http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.

=cut


=head1 CONTACT

  Please email comments or questions to the public Ensembl
  developers list at <http://lists.ensembl.org/mailman/listinfo/dev>.

  Questions may also be sent to the Ensembl help desk at
  <http://www.ensembl.org/Help/Contact>.

=head1 NAME

Bio::EnsEMBL::Compara::DBSQL::SpeciesTreeAdaptor

=head1 DESCRIPTION

  SpeciesTreeAdaptor - Adaptor for different species trees used in ensembl-compara


=head1 APPENDIX

  The rest of the documentation details each of the object methods. Internal methods are usually preceded with a _

=cut

package Bio::EnsEMBL::Compara::DBSQL::SpeciesTreeAdaptor;

use strict;
use warnings;
use Data::Dumper;

use DBI qw(:sql_types);

use Bio::EnsEMBL::Compara::SpeciesTree;
use Bio::EnsEMBL::Compara::SpeciesTreeNode;
use Bio::EnsEMBL::Compara::Graph::NewickParser;

use base ('Bio::EnsEMBL::Compara::DBSQL::BaseAdaptor');


###############
# Constructor #
###############

sub new_from_newick {
    my ($self, $newick, $label) = @_;

    my $st = Bio::EnsEMBL::Compara::Graph::NewickParser::parse_newick_into_tree($newick, 'Bio::EnsEMBL::Compara::SpeciesTreeNode');

    my $st_root = $self->db->get_SpeciesTreeNodeAdaptor->new_from_NestedSet($st);

    my $speciesTree = Bio::EnsEMBL::Compara::SpeciesTree->new();
    $speciesTree->label($label);
    $speciesTree->root($st_root);

    return $speciesTree;
}


#################
# Fetch methods #
#################

sub fetch_by_method_link_species_set_id_label {
    my ($self, $mlss_id, $label) = @_;

    my $constraint = 'method_link_species_set_id = ? AND label = ?';
    $self->bind_param_generic_fetch($mlss_id, SQL_INTEGER);
    $self->bind_param_generic_fetch(($label || 'default'), SQL_VARCHAR);
    return $self->generic_fetch_one($constraint);
}

sub fetch_all_by_method_link_species_set_id_label_pattern {
 my ($self, $mlss_id, $label) = @_; 
 $label //= '';
 my $constraint = "method_link_species_set_id = $mlss_id AND label LIKE '%$label%'";
 return  $self->generic_fetch($constraint);
}

sub fetch_by_root_id {
    my ($self, $root_id) = @_;

    my $constraint = 'root_id = ?';
    $self->bind_param_generic_fetch($root_id, SQL_INTEGER);
    return $self->generic_fetch_one($constraint);
}


########################
# Store/update methods #
########################

sub store {
    my ($self, $tree) = @_;
    
    my $mlss_id = $tree->method_link_species_set_id;

    my $species_tree_node_adaptor = $self->db->get_SpeciesTreeNodeAdaptor();

    # Store the nodes
    my $root_id = $species_tree_node_adaptor->store_nodes_rec($tree->root, $mlss_id);

    # Store the tree in the header table
    $self->generic_insert('species_tree_root', {
            'root_id'                       => $root_id,
            'method_link_species_set_id'    => $mlss_id,
            'label'                         => ($tree->label || 'default'),
        } );

    # Register the new object
    $self->attach($tree, $root_id);

    return $root_id;
}


############################################################
# Bio::EnsEMBL::Compara::DBSQL::BaseAdaptor implementation #
############################################################

sub _columns {
    return qw ( str.root_id
                str.method_link_species_set_id
                str.label
             );
}

sub _tables {
    return (['species_tree_root','str']);
}

sub _objs_from_sth {
    my ($self, $sth) = @_;
    return $self->generic_objs_from_sth($sth, 'Bio::EnsEMBL::Compara::SpeciesTree', [
            '_root_id',
            '_method_link_species_set_id',
            '_label',
        ] );
}

1;
