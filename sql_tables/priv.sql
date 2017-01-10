-- this creates the privileges db to keep track of who gets access to the keys admin site
-- DO NOT USE ON THE LIVE DATABASE!!!
-- THIS SCRIPT DELETES ALL DATA!!!

-- this script is designed for mysql version 5.1 and above

drop table IF EXISTS admin_access, priv_level;

CREATE TABLE `priv_level`(
    `priv` int(2) NOT NULL,
    `description` varchar(255) NOT NULL,
    CONSTRAINT `priv_pk` PRIMARY KEY (`priv`)
) TYPE = INNODB;

INSERT INTO `priv_level` VALUES (1,"full access");
INSERT INTO `priv_level` VALUES (2,"approver access only");

CREATE TABLE `admin_access`(
    `netid` varchar(8) NOT NULL,
    `priv` int(2) NOT NULL DEFAULT 2,
    CONSTRAINT `adminaccess_pk` PRIMARY KEY (`netid`),
    CONSTRAINT `adminacc_priv_fk` FOREIGN KEY (`priv`) REFERENCES `priv_level`(`priv`)
) TYPE = INNODB;

--  of course, clint is the default person to add
INSERT INTO `admin_access` VALUES ("cmanning",1);
INSERT INTO `admin_access` VALUES ("cholguin",1);

