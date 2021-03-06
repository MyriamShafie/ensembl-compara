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


=pod 

=head1 NAME

Bio::EnsEMBL::Compara::PipeConfig::MercatorPecan_conf

=head1 SYNOPSIS

    #1. update ensembl-hive, ensembl and ensembl-compara GIT repositories before each new release

    #3. make sure that all default_options are set correctly

    #4. Run init_pipeline.pl script:
        init_pipeline.pl Bio::EnsEMBL::Compara::PipeConfig::MercatorPecan_conf -password <your_password> -mlss_id <your_current_Pecan_mlss_id> --ce_mlss_id <constrained_element_mlss_id> --cs_mlss_id <conservation_score_mlss_id>

    #5. Sync and loop the beekeeper.pl as shown in init_pipeline.pl's output


=head1 DESCRIPTION  

    The PipeConfig file for MercatorPecan pipeline that should automate most of the pre-execution tasks.

    FYI: it took (3.7 x 24h) to perform the full production run for EnsEMBL release 62.

=head1 CONTACT

Please email comments or questions to the public Ensembl
developers list at <http://lists.ensembl.org/mailman/listinfo/dev>.

Questions may also be sent to the Ensembl help desk at
<http://www.ensembl.org/Help/Contact>.

=cut

package Bio::EnsEMBL::Compara::PipeConfig::EBI_MercatorPecan_conf;

use strict;
use warnings;

use Bio::EnsEMBL::Hive::Version 2.4;

use base ('Bio::EnsEMBL::Compara::PipeConfig::MercatorPecan_conf');


sub default_options {
    my ($self) = @_;
    return {
        %{$self->SUPER::default_options},   # inherit the generic ones


    # parameters that are likely to change from execution to another:
	#pecan mlss_id
#       'mlss_id'               => 522,   # it is very important to check that this value is current (commented out to make it obligatory to specify)
        #constrained element mlss_id
#       'ce_mlss_id'            => 523,   # it is very important to check that this value is current (commented out to make it obligatory to specify)
	#conservation score mlss_id
#       'cs_mlss_id'            => 50029, # it is very important to check that this value is current (commented out to make it obligatory to specify)
	'pipeline_name'         => 'pecan_24way',
        'work_dir'              => '/hps/nobackup/production/ensembl/' . $ENV{'USER'} . '/scratch/hive/release_' . $self->o('rel_with_suffix') . '/' . $self->o('pipeline_name'),
	'do_not_reuse_list'     => [ 134, 150,43,46,61,60,108,87,112,111,123,117,122,125,135,132,147,139,153,151],     # genome_db_ids of species we don't want to reuse this time. This is normally done automatically, so only need to set this if we think that this will not be picked up automatically.
#	'do_not_reuse_list'     => [ 142 ],     # names of species we don't want to reuse this time. This is normally done automatically, so only need to set this if we think that this will not be picked up automatically.

        'species_set' => undef, 

    # dependent parameters:
        'blastdb_dir'           => $self->o('work_dir') . '/blast_db',  
        'mercator_dir'          => $self->o('work_dir') . '/mercator',  

    # blast parameters:
	'blast_params'          => "-seg 'yes' -best_hit_overhang 0.2 -best_hit_score_edge 0.1 -use_sw_tback",
        'blast_capacity'        => 100,
        'reuse_capacity'        => 100,

    #location of full species tree, will be pruned
	    #'species_tree_file'     => $self->o('ensembl_cvs_root_dir').'/ensembl-compara/scripts/pipeline/species_tree_blength.nh', 
        'species_tree_file'     => $self->o('ensembl_cvs_root_dir').'/ensembl-compara/scripts/pipeline/species_tree.24amniots.branch_len.nw', 

    #master database
        'master_db'     => 'mysql://ensro@mysql-ens-compara-prod-1.ebi.ac.uk:4485/ensembl_compara_master',

    # Mercator default parameters
    'strict_map'        => 1,
#    'cutoff_score'     => 100,   #not normally defined
#    'cutoff_evalue'    => 1e-5, #not normally defined
    'maximum_gap'       => 50000,
    'input_dir'         => $self->o('work_dir').'/mercator',
    'all_hits'          => 0,

    #Pecan default parameters
    'max_block_size'    => 1000000,
    'java_options'      => '-server -Xmx1000M',
    'java_options_mem1' => '-server -Xmx2500M -Xms2000m',
    'java_options_mem2' => '-server -Xmx4500M -Xms4000m',
    'java_options_mem3' => '-server -Xmx6500M -Xms6000m',
#    'jar_file'          => '/nfs/users/nfs_k/kb3/src/benedictpaten-pecan-973a28b/lib/pecan.jar',
    'jar_file'          => $self->o('ensembl_cellar').'/pecan/0.8.0/pecan.jar',

    #Gerp default parameters
    'window_sizes'      => [1,10,100,500],
    'gerp_version'      => 2.1,
	    
    #Location of executables (or paths to executables)
    'populate_new_database_exe' => $self->o('ensembl_cvs_root_dir')."/ensembl-compara/scripts/pipeline/populate_new_database.pl", 
    'gerp_exe_dir'              => $self->o('ensembl_cellar').'/gerp/20080211/bin',
    'mercator_exe'              => '/nfs/software/ensembl/RHEL7/linuxbrew/bin/mercator',
    'blast_bin_dir'             => $self->o('ensembl_cellar').'/blast-2230/2.2.30/bin/',
    'exonerate_exe'             => $self->o('ensembl_cellar').'/exonerate22/2.2.0/bin/exonerate',

    'dump_features_exe' => $self->o('ensembl_cvs_root_dir')."/ensembl-compara/scripts/dumps/dump_features.pl",
    'compare_beds_exe' => $self->o('ensembl_cvs_root_dir')."/ensembl-compara/scripts/pipeline/compare_beds.pl",

    #
    #Default statistics
    #
    'skip_multiplealigner_stats' => 0, #skip this module if set to 1
    'bed_dir' => '/hps/nobackup/production/ensembl/' . $ENV{USER} . '/pecan/bed_dir/' . 'release_' . $self->o('rel_with_suffix') . '/',
    'output_dir' => '/hps/nobackup/production/ensembl/' . $ENV{USER} . '/pecan/feature_dumps/' . 'release_' . $self->o('rel_with_suffix') . '/',

    'production_db_url'     => 'mysql://ensro@mysql-ens-sta-1:4519/ensembl_production',
    # connection parameters to various databases:

        'host'        => 'mysql-ens-compara-prod-2.ebi.ac.uk',            #separate parameter to use the resources aswell
        'pipeline_db' => {                      # the production database itself (will be created)
            -host   => $self->o('host'),
            -port   => 4522,
            -user   => 'ensadmin',
            -pass   => $self->o('password'),                    
            -dbname => $ENV{'USER'}.'_pecan_24way_'.$self->o('rel_with_suffix'),
	    -driver => 'mysql',
        },

        'staging_loc' => {                     # general location of half of the current release core databases
            -host   => 'mysql-ens-sta-1',
            -port   => 4519,
            -user   => 'ensro',
            -pass   => '',
        },

        'livemirror_loc' => {                   # general location of the previous release core databases (for checking their reusability)
            -host   => 'mysql-ensembl-mirror.ebi.ac.uk',
            -port   => 4240,
            -user   => 'anonymous',
            -pass   => '',
        },
        # "production mode"
       'reuse_core_sources_locs'   => [ $self->o('livemirror_loc') ],
       'curr_core_sources_locs'    => [ $self->o('staging_loc')],

       'reuse_db' => {   # usually previous pecan production database
           -host   => 'mysql-ens-compara-prod-2.ebi.ac.uk',
           -port   => 4522,
           -user   => 'ensro',
           -pass   => '',
           -dbname => 'sf5_pecan_23way_pt2_77',
	   -driver => 'mysql',
        },

	#Testing mode
        'reuse_loc' => {                   # general location of the previous release core databases (for checking their reusability)
            -host   => 'ensembldb.ensembl.org',
            -port   => 3306,
            -user   => 'anonymous',
            -pass   => '',
        },

        'curr_loc' => {                   # general location of the current release core databases (for checking their reusability)
            -host   => 'mysql-ensembl-mirror.ebi.ac.uk',
            -port   => 4240,
            -user   => 'anonymous',
            -pass   => '',
            -db_version => '88'
        },
#        'reuse_core_sources_locs'   => [ $self->o('reuse_loc') ],
#        'curr_core_sources_locs'    => [ $self->o('curr_loc'), ],
#        'reuse_db' => {   # usually previous production database
#           -host   => 'compara4',
#           -port   => 3306,
#           -user   => 'ensro',
#           -pass   => '',
#           -dbname => 'kb3_pecan_19way_61',
#        },


     # stats report email
     'epo_stats_report_exe' => $self->o('ensembl_cvs_root_dir')."/ensembl-compara/scripts/production/epo_stats.pl",
     'epo_stats_report_email' => $ENV{'USER'} . '@ebi.ac.uk',
    };
}


sub resource_classes {
    my ($self) = @_;
    return {
         %{$self->SUPER::resource_classes},  # inherit 'default' from the parent class
         '100Mb' =>  { 'LSF' => '-C0 -M100 -R"select[mem>100] rusage[mem=100]"' },
         '1Gb' =>    { 'LSF' => '-C0 -M1000 -R"select[mem>1000] rusage[mem=1000]"' },
         '1.8Gb' =>  { 'LSF' => '-C0 -M1800 -R"select[mem>1800] rusage[mem=1800]"' },
         '3.6Gb' =>  { 'LSF' => '-C0 -M3600 -R"select[mem>3600] rusage[mem=3600]"' },
         '7.5Gb' =>  { 'LSF' => '-C0 -M7500 -R"select[mem>7500] rusage[mem=7500]"' },
         '11.4Gb' => { 'LSF' => '-C0 -M11400 -R"select[mem>11400] rusage[mem=11400]"' },
         '14Gb' =>   { 'LSF' => '-C0 -M14000 -R"select[mem>14000] rusage[mem=14000]"' },
         '14Gb_long_job' =>   { 'LSF' => '-C0 -M14000 -R"select[mem>14000] rusage[mem=14000]" -q long' }, 
         'gerp' =>   { 'LSF' => '-C0 -M1000 -R"select[mem>1000] rusage[mem=1000]"' },
         'higerp' =>   { 'LSF' => '-C0 -M3800 -R"select[mem>3800] rusage[mem=3800]"' },
    };
}

1;

