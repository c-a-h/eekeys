-- this creates the new keys database
-- DO NOT USE ON THE LIVE DATABASE!!!
-- THIS SCRIPT DELETES ALL DATA!!!

-- this script is designed for mysql version 5.1 and above

-- the drop table syntax below is for the ancient version 3.whatever, which
-- is still running all the EE databases

-- drop table key_people IF EXISTS cascade;
-- drop table approver IF EXISTS cascade;
-- drop table key_inventory IF EXISTS cascade;
-- drop table key_types IF EXISTS cascade;
-- drop table desks IF EXISTS cascade;
-- drop table key_info IF EXISTS cascade;

-- this is the *almost* final version

-- the order that you drop tables is important because of referential integrity!
drop table IF EXISTS
     assignments, card_access, approvers, desks, key_info, ownership, rooms, status, key_inventory, buildings, buildings_to_show, key_types, key_people;

-- NO GROUP PERMISSIONS FOR NOW
-- CREATE TABLE `group_permission` (
--    `auto_ind` int(10) NOT NULL AUTO_INCREMENT,
--    `status` varchar(10) NOT NULL,
--    `standing` varchar(12) NOT NULL,
--    `group_perm_type` varchar(12) NOT NULL DEFAULT `normal`,
--    CONSTRAINT `groupperm_pk` PRIMARY KEY (`auto_ind`),
--    CONSTRAINT `groupperm_permdetails_fk` FOREIGN KEY (`group_perm_type`) REFERENCES `permission_details` (`group_perm_type`)
--    --FINISH THIS (FOREIGN KEYS, VARCHAR LENGTH, ADD TO KEY_PEOPLE - NEED TO ADD STUFF TO DROP TABLE AS WELL!!!
-- ) TYPE = INNODB;
--
-- CREATE TABLE `permission_details` (
--    `group_perm_type` varchar(12) NOT NULL,
--    `function_type` varchar(12) NOT NULL,
--    `comment` varchar(255),
--    CONSTRAINT.....
--    --FINISH THIS - NEED TO ADD STUFF TO DROP TABLE AS WELL!!! need to add foreign keys etc
--    --STILL NEED TO THINK ABOUT HOW TO HANDLE THE DIFFERENT BUILDINGS AND SHIT
-- ) TYPE = INNODB;

CREATE TABLE `key_people`(
    `netid` varchar(32) NOT NULL,
    -- `fname` varchar(40) NOT NULL,
    -- `lname` varchar(40) NOT NULL,
    `display_name` varchar(80) NOT NULL,
    `nine_num` int(9),
    `ug_grad_date` date,
    `primary_affil` varchar(15),
    CONSTRAINT `keypeople_uk1` UNIQUE KEY (`nine_num`), 
    CONSTRAINT `key_people_pk` PRIMARY KEY (`netid`)
) TYPE = INNODB;


CREATE TABLE `key_types` (
    `types` varchar(20) NOT NULL,
    `description` varchar(255),
    CONSTRAINT `key_types_pk` PRIMARY KEY (`types`)
) TYPE = INNODB;

INSERT INTO `key_types` VALUES ("NS","not specified");

-- buildings table tells the scripts which buildings to display (since we're basing it on EE_Places db)
CREATE TABLE `buildings_to_show` (
    `id` varchar(8) NOT NULL,
    `description` varchar(32),
    CONSTRAINT `buildtoshow_pk` PRIMARY KEY (`id`)
) TYPE = INNODB;

INSERT INTO `buildings_to_show` VALUES ("CUSH","cushing hall");
INSERT INTO `buildings_to_show` VALUES ("FITZ","fitzpatrick hall");
INSERT INTO `buildings_to_show` VALUES ("STRM","stinson-remick");
INSERT INTO `buildings_to_show` VALUES ("OTHER","this is a catch all, not to be used often");

-- buildings table

CREATE TABLE `buildings` (
    `id` varchar(8) NOT NULL,
    `friendly_name` varchar(255),
    `picture_path` varchar(64),
    CONSTRAINT `buildings_pk` PRIMARY KEY (`id`)
) TYPE = INNODB;

INSERT INTO `buildings` VALUES ("OTHER","this is just a catch all","");

CREATE TABLE `key_inventory` (
    -- `inv_id` int(10) NOT NULL AUTO_INCREMENT,
    `keynum` varchar(32) NOT NULL,
    `types` varchar(20), -- THIS IS NOT USUALLY BLANK, BUT FOR DATA IMPORT NEED TO ALLOW NULLS
    `key_qty` int(4) NOT NULL DEFAULT 0,
    `tag_number` varchar(32),
    `basket_qty` int(4), -- this is simply a counter for how many keys are in the basket, or equally ,not in the drawer but still returned
    `comments` varchar(255),
    CONSTRAINT `key_inventory_pk` PRIMARY KEY (`keynum`),
    CONSTRAINT `keyinv_keytype_fk` FOREIGN KEY (`types`) REFERENCES `key_types` (`types`)
    ON UPDATE CASCADE
    ON DELETE RESTRICT
) TYPE = INNODB;
INSERT INTO `key_inventory` VALUES ("owner_key","NS",0,"DONT USE",0,"DONT USE THIS KEY FOR ANYTHING OTHER THAN INDICATING WHO THE OWNER OF A ROOM IS");
INSERT INTO `key_inventory` VALUES ("approver_key","NS",0,"DONT USE",0,"DONT USE THIS KEY FOR ANYTHING OTHER THAN INDICATING WHO THE approver OF A ROOM IS");

CREATE TABLE `status`(
       `status_num` int(2) NOT NULL,
       `description` varchar(255),
       CONSTRAINT `status_pk` PRIMARY KEY (`status_num`)
)TYPE = INNODB;

-- below are the default status values
INSERT INTO `status` VALUES (1,"pending approval - for key assignment table only");
INSERT INTO `status` VALUES (2,"approved - for key assignment table only");
INSERT INTO `status` VALUES (3,"filled - for key assignment table only");
INSERT INTO `status` VALUES (4,"issued - for key assignment table only");
INSERT INTO `status` VALUES (9,"expired - for card access in key assignment table only");

INSERT INTO `status` VALUES (20,"current approver- for approvers table only");
INSERT INTO `status` VALUES (21,"inactive - for approvers  table only");

INSERT INTO `status` VALUES (30,"active - for key info table only");
INSERT INTO `status` VALUES (32,"this is the owner key status number don't use for anything else - for key_info or approver table");
INSERT INTO `status` VALUES (33,"this status means approver, but not owner - only for approver table");
INSERT INTO `status` VALUES (31,"inactive - for key info table only");

INSERT INTO `status` VALUES (40,"active - for ROOMS table only");
INSERT INTO `status` VALUES (41,"inactive - for ROOMS table only");

-- rooms table
CREATE TABLE `rooms` (
    `roomnum` varchar(32) NOT NULL,
    `bldg_id` varchar(8) NOT NULL,
    `phone` varchar(20),
    `friendly_name` varchar(100) NOT NULL,
    `function` text,
    `stat_num` int(2) NOT NULL DEFAULT 40,
    CONSTRAINT `rooms_pk` PRIMARY KEY (`roomnum`,`bldg_id`),
    CONSTRAINT `rooms_bldgid_fk` FOREIGN KEY (`bldg_id`) REFERENCES `buildings` (`id`) ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT `rooms_status_fk` FOREIGN KEY (`stat_num`) REFERENCES `status` (`status_num`) ON UPDATE CASCADE ON DELETE RESTRICT
) TYPE = INNODB;

CREATE TABLE `ownership` (
    `room` varchar(32) NOT NULL,
    `bldg` varchar(8) NOT NULL,
    `owner_netid` varchar(32) NOT NULL,
    CONSTRAINT `owner_pk` PRIMARY KEY (`room`,`bldg`,`owner_netid`),
    CONSTRAINT `owner_room_fk` FOREIGN KEY (`room`,`bldg`) REFERENCES `rooms` (`roomnum`,`bldg_id`) ON UPDATE CASCADE ON DELETE RESTRICT
) TYPE = INNODB;

CREATE TABLE `key_info`(
    `info_id` int(10) NOT NULL AUTO_INCREMENT,
    `keynum` varchar(32) NOT NULL,
    `bldg_code` varchar(8) NOT NULL,
    `roomnum` varchar(32) NOT NULL,
    `comment` varchar(255),
    `status_num` int(2) NOT NULL DEFAULT 30,
    CONSTRAINT `keyinfo_uk` UNIQUE KEY (`info_id`),
    CONSTRAINT `keyinfo_pk` PRIMARY KEY (`keynum`, `bldg_code`,`roomnum`),
    CONSTRAINT `keyinfo_roombldg_fk` FOREIGN KEY (`roomnum`,`bldg_code`) REFERENCES `rooms` (`roomnum`,`bldg_id`) ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT `keyinfo_keynum_fk` FOREIGN KEY (`keynum`) REFERENCES `key_inventory` (`keynum`) ON UPDATE RESTRICT ON DELETE RESTRICT,
    CONSTRAINT `keyinfo_status_fk` FOREIGN KEY (`status_num`) REFERENCES `status` (`status_num`) ON UPDATE CASCADE ON DELETE RESTRICT
)TYPE = INNODB;


CREATE TABLE `desks`(
    `key_info_id` int(10) NOT NULL,
    `desk_num` int(10) NOT NULL,
    `key_r` varchar(32),
    `key_c` varchar(32),
    `key_l` varchar(32),
    `comments` varchar(255),
    CONSTRAINT `desks_pk` PRIMARY KEY (`key_info_id`, `desk_num`),
    CONSTRAINT `desks_keyinfid_fk` FOREIGN KEY (`key_info_id`) REFERENCES `key_info` (`info_id`) ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT `desks_keyr_fk` FOREIGN KEY (`key_r`) REFERENCES `key_inventory` (`keynum`) ON UPDATE RESTRICT ON DELETE RESTRICT,
    CONSTRAINT `desks_keyc_fk` FOREIGN KEY (`key_c`) REFERENCES `key_inventory` (`keynum`) ON UPDATE RESTRICT ON DELETE RESTRICT,
    CONSTRAINT `desks_keyl_fk` FOREIGN KEY (`key_l`) REFERENCES `key_inventory` (`keynum`) ON UPDATE RESTRICT ON DELETE RESTRICT
) TYPE = INNODB;

CREATE TABLE `approvers` (
    `approver_id` int(10) NOT NULL AUTO_INCREMENT,
    `netid` varchar(10) NOT NULL,
    `key_info_id` int(8) NOT NULL,
    `created_date` date NOT NULL,
    `deactivated_date` date,
    `status` int(2) NOT NULL DEFAULT 20,
    `comments` varchar(255),
    CONSTRAINT `approvers_index` UNIQUE KEY (`approver_id`),
    CONSTRAINT `approvers_pk` PRIMARY KEY (`netid`,`key_info_id`),
    CONSTRAINT `approvers_keyinfid_fk` FOREIGN KEY (`key_info_id`) REFERENCES `key_info` (`info_id`) ON UPDATE CASCADE ON DELETE RESTRICT,
    -- CONSTRAINT `approvers_keypeople_fk` FOREIGN KEY (`netid`) REFERENCES `key_people` (`netid`),
    CONSTRAINT `approvers_status_fk` FOREIGN KEY (`status`) REFERENCES `status` (`status_num`) ON UPDATE CASCADE ON DELETE RESTRICT
    -- note: might want to link netid to persons table at some point
) TYPE = INNODB;

CREATE TABLE `card_access` (
    `type` int(2) NOT NULL,
    `description` varchar(255),
    CONSTRAINT `card_access_pk` PRIMARY KEY (`type`)
) TYPE = INNODB;

INSERT INTO `card_access` VALUES (0,"not set, assume normal access only");
INSERT INTO `card_access` VALUES (1,"after hours access");
INSERT INTO `card_access` VALUES (2,"normal access only");
INSERT INTO `card_access` VALUES (3,"n/a-only used from data import");
-- INSERT INTO `card_access` VALUES (2,"after hours");

-- assignments table--most important
CREATE TABLE `assignments`(
       `record_id` int(10) NOT NULL AUTO_INCREMENT,
       `user_netid` varchar(32) NOT NULL, 
       `key_info_id` int(8) NOT NULL,
       `approver_netid` varchar(10) NOT NULL, /* NOT LINKED to people table because approvers don't have to be in there */
       `approver_id` int(10), /* THIS SHOULD NOT USUALLY BE EMPTY, BUT MIGHT BE IN SOME RARE CASES */
       `request_date` date NOT NULL,
       `assigned_date` date,
       `returned_date` date,
       `card_expire` date,
       `card_access_type` int(2),
       `status_num` int(2) NOT NULL,
       `comments` varchar(255),
       CONSTRAINT `assignments_index` UNIQUE KEY (`record_id`),
       CONSTRAINT `assignments_pk` PRIMARY KEY (`user_netid`,`key_info_id`,`request_date`),
       CONSTRAINT `assignments_netid_fk` FOREIGN KEY (`user_netid`) REFERENCES `key_people` (`netid`) ON UPDATE CASCADE ON DELETE RESTRICT,
       CONSTRAINT `assignments_keyinfo_fk` FOREIGN KEY (`key_info_id`) REFERENCES `key_info` (`info_id`) ON UPDATE CASCADE ON DELETE RESTRICT,
       CONSTRAINT `assignments_status_fk` FOREIGN KEY (`status_num`) REFERENCES `status` (`status_num`) ON UPDATE CASCADE ON DELETE RESTRICT,
       CONSTRAINT `assignments_approvers_fk` FOREIGN KEY (`approver_id`) REFERENCES `approvers` (`approver_id`) ON UPDATE CASCADE ON DELETE RESTRICT,
       CONSTRAINT `assignments_cardaccess_fk` FOREIGN KEY (`card_access_type`) REFERENCES `card_access` (`type`)ON UPDATE CASCADE ON DELETE RESTRICT
)TYPE = INNODB;


