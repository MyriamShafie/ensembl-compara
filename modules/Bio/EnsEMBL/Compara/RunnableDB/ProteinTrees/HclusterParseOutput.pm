=head1 LICENSE

  Copyright (c) 1999-2013 The European Bioinformatics Institute and
  Genome Research Limited.  All rights reserved.

  This software is distributed under a modified Apache license.
  For license details, please see

   http://www.ensembl.org/info/about/code_licence.html

=head1 CONTACT

  Please email comments or questions to the public Ensembl
  developers list at <dev@ensembl.org>.

  Questions may also be sent to the Ensembl help desk at
  <helpdesk@ensembl.org>.

=head1 NAME

Bio::EnsEMBL::Compara::RunnableDB::ProteinTrees::HclusterParseOutput

=head1 DESCRIPTION

This is the RunnableDB that parses the output of Hcluster, stores the
clusters as trees without internal structure (each tree will have one
root and several leaves) and dataflows the cluster_ids down branch #2.

=head1 SYNOPSIS

my $aa = $sdba->get_AnalysisAdaptor;
my $analysis = $aa->fetch_by_logic_name('HclusterParseOutput');
my $rdb = new Bio::EnsEMBL::Compara::RunnableDB::ProteinTrees::HclusterParseOutput(
                         -input_id   => "{'mlss_id'=>40069}",
                         -analysis   => $analysis);

$rdb->fetch_input
$rdb->run;

=head1 AUTHORSHIP

Ensembl Team. Individual contributions can be found in the CVS log.

=head1 MAINTAINER

$Author$

=head VERSION

$Revision$

=head1 APPENDIX

The rest of the documentation details each of the object methods.
Internal methods are usually preceded with an underscore (_)

=cut

package Bio::EnsEMBL::Compara::RunnableDB::ProteinTrees::HclusterParseOutput;

use strict;

use base ('Bio::EnsEMBL::Compara::RunnableDB::GeneTrees::StoreClusters');

sub param_defaults {
    return {
            'sort_clusters'         => 1,
            'immediate_dataflow'    => 1,
            'member_type'           => 'protein',
    };
}


# If the job is being re-run, make sure we don't have any clusters left from the previous run
sub pre_cleanup {
    my $self = shift;
    $self->compara_dba->dbc->do('UPDATE gene_tree_node SET root_id = NULL, parent_id = NULL');
    foreach my $table (qw(gene_tree_root_tag gene_tree_root gene_tree_node)) {
        $self->compara_dba->dbc->do("DELETE FROM $table");
    }
}

sub run {
    my $self = shift @_;

    $self->parse_hclusteroutput;
}


sub write_output {
    my $self = shift @_;

    $self->store_clusterset('default', $self->param('allclusters'));

    if (defined $self->param('additional_clustersets')) {
        foreach my $clusterset_id (@{$self->param('additional_clustersets')}) {
            $self->create_clusterset($clusterset_id);
        }
    }
}


##########################################
#
# internal methods
#
##########################################

sub parse_hclusteroutput {
    my $self = shift;

    my $filename      = $self->param('cluster_dir') . '/hcluster.out';
    my $division      = $self->param('division'),

    my %allclusters = ();
    $self->param('allclusters', \%allclusters);
    
    open(FILE, $filename) or die "Could not open '$filename' for reading : $!";
    while (<FILE>) {
        # 0       0       0       1.000   2       1       697136_68,
        # 1       0       39      1.000   3       5       1213317_31,1135561_22,288182_42,426893_62,941130_38,
        chomp $_;

        my ($cluster_id, $dummy1, $dummy2, $dummy3, $dummy4, $cluster_size, $cluster_list) = split("\t",$_);

        next if ($cluster_size < 2);
        $cluster_list =~ s/\,$//;
        $cluster_list =~ s/_[0-9]*//g;
        my @cluster_list = split(",", $cluster_list);

        # If it's a singleton, we don't store it as a protein tree
        next if (2 > scalar(@cluster_list));
        $allclusters{$cluster_id} = { 'members' => \@cluster_list };
        $allclusters{$cluster_id}->{'division'} = $division if $division;
    }
    close FILE;

}


1;
