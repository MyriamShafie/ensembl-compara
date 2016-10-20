-- Copyright [1999-2015] Wellcome Trust Sanger Institute and the EMBL-European Bioinformatics Institute
-- Copyright [2016] EMBL-European Bioinformatics Institute
-- 
-- Licensed under the Apache License, Version 2.0 (the "License");
-- you may not use this file except in compliance with the License.
-- You may obtain a copy of the License at
-- 
--      http://www.apache.org/licenses/LICENSE-2.0
-- 
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.

# patch_85_86_f.sql
#
# Title: Add a "seq_member_projection" table
#
# Description:
#   The table will be used to hold genebuild information about transcript
#   projections. The pipelines will use the table to classify the projections
#   in the same clusters as their source


CREATE TABLE seq_member_projection (
  source_seq_member_id      int(10) unsigned NOT NULL,
  target_seq_member_id      int(10) unsigned NOT NULL,

  PRIMARY KEY (target_seq_member_id),
  KEY (source_seq_member_id)
) ENGINE=MyISAM;

# Patch identifier
INSERT INTO meta (species_id, meta_key, meta_value)
  VALUES (NULL, 'patch', 'patch_85_86_f.sql|seq_member_projection');

