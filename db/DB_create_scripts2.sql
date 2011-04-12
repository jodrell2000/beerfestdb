--
-- This file is part of BeerFestDB, a beer festival product management
-- system.
-- 
-- Copyright (C) 2010 Roger Stark and Tim F. Rayner
--
-- This program is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.
--
-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
--
-- You should have received a copy of the GNU General Public License
-- along with this program.  If not, see <http://www.gnu.org/licenses/>.
--
-- $Id$
--
--
-- ------------------------------------------------------------
-- Table structure for table `currency`
-- Stores a ISO standard currency code exponent usually 0,2,3. Database should
-- store all amounts as integers so there is not a loss of presision with 
-- decimal/floats. Format dor example are '#0','#0.00','#0.000' where there 
-- are any ',' and '.' to allow currency specific formatting of amounts id 
-- required any number of '#' are used in any desired format so for GBP with
-- comma separated 1000's and '.' as minor separatot the format would be
-- '#,###,###,###,##0.00' and JPY '#,###,###,###,##0'. All currencies except
--  the Malagasy ariary, and Mauritanian Ouguiya fit into thsi structure.
-- ------------------------------------------------------------

CREATE TABLE currency (
  currency_id INT(6) NOT NULL AUTO_INCREMENT,
  currency_code CHAR(3) NOT NULL,
  currency_number CHAR(3) NOT NULL,
  currency_format VARCHAR(20) NOT NULL,
  exponent TINYINT(4) NOT NULL,
  currency_symbol VARCHAR(10) NOT NULL,
  PRIMARY KEY(currency_id),
  UNIQUE KEY(currency_code),
  INDEX CUR_currencynumber(currency_number)
)
TYPE=InnoDB DEFAULT CHARSET=utf8;

-- ------------------------------------------------------------
-- Table structure for table `festival`
-- Simple table storing information about the festival, auto generated id as
-- the primary key as nothing else is unique. The start_date and end_date are
-- for use a a broad indication of when the festival is running not when it
-- is opening, see festival_opening for that.
-- 
-- ------------------------------------------------------------

CREATE TABLE festival (
  festival_id INTEGER(6) NOT NULL AUTO_INCREMENT,
  year YEAR(4) NOT NULL,
  name VARCHAR(60) NOT NULL,
  description TEXT NULL,
  fst_start_date DATE NULL,
  fst_end_date DATE NULL,
  PRIMARY KEY(festival_id)
)
TYPE=InnoDB DEFAULT CHARSET=utf8;

-- ------------------------------------------------------------
-- Table structure for table `container_measure`
-- Simple table to store a multiplier so all container types can be converted into the same volume e.g. from litres into gallons
-- Note that we have to make description unique not null since retrieving a row based on a float value seems to be questionable in MySQL.
-- ------------------------------------------------------------

CREATE TABLE container_measure (
  container_measure_id INTEGER(6) NOT NULL AUTO_INCREMENT,
  litre_multiplier FLOAT NOT NULL,
  description VARCHAR(50) NOT NULL,
  PRIMARY KEY(container_measure_id),
  UNIQUE KEY(description)
)
TYPE=InnoDB DEFAULT CHARSET=utf8;


INSERT INTO container_measure (litre_multiplier, description) VALUES(1, 'litre');
INSERT INTO container_measure (litre_multiplier, description) VALUES(4.54609188,'gallon');
INSERT INTO container_measure (litre_multiplier, description) VALUES(0.5682,'pint');
INSERT INTO container_measure (litre_multiplier, description) VALUES(0.2841,'half pint');


-- ------------------------------------------------------------
-- Table structure fortable `country`
-- Simple table to be able to refer to a country by a code rather than name if
-- various other table (an example might be a contact/address). Primary key 
-- country_code_iso2.
-- ------------------------------------------------------------

CREATE TABLE country (
  country_id INTEGER(6) NOT NULL AUTO_INCREMENT,
  country_code_iso2 CHAR(2) NOT NULL,
  country_code_iso3 CHAR(3) NOT NULL,
  country_code_num3 CHAR(3) NOT NULL,
  country_name VARCHAR(100) NOT NULL,
  PRIMARY KEY(country_id),
  INDEX IDX_CNTRY_countrycode3(country_code_iso3),
  INDEX IDX_CNTRY_countrynum3(country_code_num3)
)
TYPE=InnoDB DEFAULT CHARSET=utf8;


INSERT INTO country (country_code_iso2, country_code_iso3, country_code_num3, country_name) VALUES ('GB','GBR', '826', 'Great Britain');
INSERT INTO country (country_code_iso2, country_code_iso3, country_code_num3, country_name) VALUES ('IE','IRL', '372', 'Ireland');
INSERT INTO country (country_code_iso2, country_code_iso3, country_code_num3, country_name) VALUES ('NL','NLD', '528', 'Netherlands');
INSERT INTO country (country_code_iso2, country_code_iso3, country_code_num3, country_name) VALUES ('DE','DEU', '276', 'Germany');
INSERT INTO country (country_code_iso2, country_code_iso3, country_code_num3, country_name) VALUES ('BE','BEL', '056', 'Belgium');
INSERT INTO country (country_code_iso2, country_code_iso3, country_code_num3, country_name) VALUES ('CZ','CZE', '203', 'Czech Republic');


-- ------------------------------------------------------------
-- Table structure for table `stillage_location`

-- stillage_location_id is autogenerated. The description is the
-- physical location of some particular stillageing for example 'main
-- tent','staff tent',igloo'. See also the bar table for public-facing
-- information. Note that stillage locations are not re-used between festivals.
-- ------------------------------------------------------------

CREATE TABLE stillage_location (
  stillage_location_id INTEGER(6) NOT NULL AUTO_INCREMENT,
  festival_id INTEGER(6) NOT NULL,
  description VARCHAR(50) NOT NULL,
  PRIMARY KEY(stillage_location_id),
  UNIQUE KEY(festival_id, description),
  FOREIGN KEY FK_STL_fstid_FST_fstid(festival_id)
    REFERENCES festival(festival_id)
      ON DELETE RESTRICT
      ON UPDATE NO ACTION
)
TYPE=InnoDB DEFAULT CHARSET=utf8;

-- ------------------------------------------------------------
-- Static Table structure for table `telephone_type`
-- Simple table that describes different types of telephone that a telephone
-- is one of e.g. telephone,fax,mobile.
-- ------------------------------------------------------------

CREATE TABLE telephone_type (
  telephone_type_id INTEGER(6) NOT NULL AUTO_INCREMENT,
  description VARCHAR(30) NOT NULL,
  PRIMARY KEY(telephone_type_id),
  UNIQUE KEY(description)
)
TYPE=InnoDB DEFAULT CHARSET=utf8;

INSERT INTO telephone_type (description) VALUES('landline');
INSERT INTO telephone_type (description) VALUES('fax');
INSERT INTO telephone_type (description) VALUES('mobile');


-- ------------------------------------------------------------
-- Table structure for table `festival_entry_type`
-- Simple table to contain a list of the different types of entry that are 
-- allowed, such as FULL, CAMRA, Student etc. The festival_entry_type_id
-- is autogenerated
-- ------------------------------------------------------------

CREATE TABLE festival_entry_type (
  festival_entry_type_id INTEGER(6) NOT NULL AUTO_INCREMENT,
  description VARCHAR(30) NOT NULL,
  PRIMARY KEY(festival_entry_type_id),
  UNIQUE KEY(description)
)
TYPE=InnoDB DEFAULT CHARSET=utf8;

-- ------------------------------------------------------------
-- Table structure for table `product_category`
-- Simple table to store a list of the product categories that we sell. These 
-- would simply be things like 'beer','cider', 'perry','foreign beer'
-- ------------------------------------------------------------

CREATE TABLE product_category (
  product_category_id INTEGER(6) NOT NULL AUTO_INCREMENT,
  description VARCHAR(100) NOT NULL,
  PRIMARY KEY(product_category_id),
  UNIQUE KEY(description)
)
TYPE=InnoDB DEFAULT CHARSET=utf8;


INSERT INTO product_category (description) VALUES ('beer');
INSERT INTO product_category (description) VALUES ('foreign beer');
INSERT INTO product_category (description) VALUES ('cider');
INSERT INTO product_category (description) VALUES ('wine');
INSERT INTO product_category (description) VALUES ('perry');
INSERT INTO product_category (description) VALUES ('cyser');
INSERT INTO product_category (description) VALUES ('mead');


-- ------------------------------------------------------------
-- Table structure for table `contact_type`
-- Simple table to store the different types of contact that there may be 
-- against a contact. Examples may be 'main', 'invoice'
-- ------------------------------------------------------------

CREATE TABLE contact_type (
  contact_type_id INTEGER(6) NOT NULL AUTO_INCREMENT,
  description VARCHAR(30) NOT NULL,
  PRIMARY KEY(contact_type_id),
  UNIQUE KEY(description)
)
TYPE=InnoDB DEFAULT CHARSET=utf8;


INSERT INTO contact_type (description) VALUES ('Main');
INSERT INTO contact_type (description) VALUES ('Customer Service');


-- ------------------------------------------------------------
-- Table structure for table `company_region`
-- Simple table to store the approximate region in which the company is located. 
-- ------------------------------------------------------------

CREATE TABLE company_region (
  company_region_id INTEGER(6) NOT NULL AUTO_INCREMENT,
  description VARCHAR(30) NOT NULL,
  PRIMARY KEY(company_region_id),
  UNIQUE KEY(description)
)
TYPE=InnoDB DEFAULT CHARSET=utf8;

INSERT INTO company_region (description) VALUES ('Wales');
INSERT INTO company_region (description) VALUES ('Scotland');
INSERT INTO company_region (description) VALUES ('Northern Ireland');
INSERT INTO company_region (description) VALUES ('East Anglia');
INSERT INTO company_region (description) VALUES ('Cambridgeshire');
INSERT INTO company_region (description) VALUES ('North England');
INSERT INTO company_region (description) VALUES ('South England');
INSERT INTO company_region (description) VALUES ('Midlands');

-- ------------------------------------------------------------
-- Table structure for table `company`
-- Simple table to store the basic details of a company be that a brewery of
-- some other suplier such as a cider maker. A company can have more than one
-- contact through the compant_contact table.
-- ------------------------------------------------------------

CREATE TABLE company (
  company_id INTEGER(6) NOT NULL AUTO_INCREMENT,
  name VARCHAR(100) NOT NULL,
  full_name VARCHAR(255) NULL,
  loc_desc VARCHAR(100) NULL,
  company_region_id INTEGER(6),
  year_founded YEAR(4) NULL,
  url VARCHAR(255) NULL,
  comment TEXT NULL,
  PRIMARY KEY(company_id),
  UNIQUE KEY(name),
  FOREIGN KEY FK_CO_rgnid_RGN_rgnid(company_region_id)
    REFERENCES company_region(company_region_id)
      ON DELETE RESTRICT
      ON UPDATE NO ACTION
)
TYPE=InnoDB DEFAULT CHARSET=utf8;

-- ------------------------------------------------------------
-- Table structure for table `bar`

-- Simple tabel to store the description of a single bar instance at a
-- single festival. Since we're using these bars to identify which
-- casks belong to each bar (e.g. for programme purposes) we don't
-- want to carry bars over between festivals. This means we don't have
-- to track the festival in order to work within a bar, so is simpler
-- than the original schema. Given that a typical festival has only a
-- few bars this should not lead to an explosion in the number of
-- table rows.  This is a descriptive table and is not regarded as for
-- use in actual positioning of casks within a bar (see
-- stillage_location). The is_private column is used to indicate staff
-- bar etc. which should not be exported for public consumption.
-- ------------------------------------------------------------

CREATE TABLE bar (
  bar_id INTEGER(6) NOT NULL AUTO_INCREMENT,
  festival_id INTEGER(6) NOT NULL,
  description VARCHAR(255) NOT NULL,
  is_private TINYINT(1) NULL,
  PRIMARY KEY(bar_id),
  UNIQUE KEY(description),
  FOREIGN KEY FK_BAR_fstid_FST_fstid(festival_id)
    REFERENCES festival(festival_id)
      ON DELETE RESTRICT
      ON UPDATE NO ACTION
)
TYPE=InnoDB DEFAULT CHARSET=utf8;

-- ------------------------------------------------------------
-- Contains a list of characteristics about a particular product category
-- ------------------------------------------------------------

CREATE TABLE product_characteristic_type (
  product_characteristic_type_id INTEGER(6) NOT NULL AUTO_INCREMENT,
  product_category_id INTEGER(6) NOT NULL,
  description VARCHAR(50) NOT NULL,
  PRIMARY KEY(product_characteristic_type_id, product_category_id),
  UNIQUE KEY(product_category_id, description),
  FOREIGN KEY FK_PC_pcid_PCT_pcid(product_category_id)
    REFERENCES product_category(product_category_id)
      ON DELETE RESTRICT
      ON UPDATE RESTRICT
)
TYPE=InnoDB DEFAULT CHARSET=utf8;

-- ------------------------------------------------------------
-- Table structure for table `festival_opening`
-- Simple table for storing all the festival opening sessions, with a 
-- festival_opening_id auto generated with the start_date, end_date.
-- References fetival by vestival_id
-- add last orders as date? 
-- ------------------------------------------------------------

CREATE TABLE festival_opening (
  festival_opening_id INTEGER(6) NOT NULL AUTO_INCREMENT,
  festival_id INTEGER(6) NOT NULL,
  op_start_date DATETIME NOT NULL,
  op_end_date DATETIME NOT NULL,
  PRIMARY KEY(festival_opening_id),
  FOREIGN KEY FK_FO_fo_FE_fo(festival_id)
    REFERENCES festival(festival_id)
      ON DELETE RESTRICT
      ON UPDATE NO ACTION
)
TYPE=InnoDB DEFAULT CHARSET=utf8;

-- ------------------------------------------------------------
-- Table structure for table `container_size`
-- Simple table to be able to refer to a container_size by a container_size_id
-- rather than name name.
-- ------------------------------------------------------------

CREATE TABLE container_size (
  container_size_id INTEGER(6) NOT NULL AUTO_INCREMENT,
  container_volume DECIMAL(4,2) NOT NULL,
  container_measure_id INTEGER(6) NOT NULL,
  description VARCHAR(100) NULL,
  PRIMARY KEY(container_size_id),
  UNIQUE KEY(description),
  FOREIGN KEY FK_CS_cmid_CM_cmid(container_measure_id)
    REFERENCES container_measure(container_measure_id)
      ON DELETE RESTRICT
      ON UPDATE NO ACTION
)
TYPE=InnoDB DEFAULT CHARSET=utf8;

INSERT INTO container_size (container_volume, container_measure_id, description) VALUES (9,2,'firkin'); 
INSERT INTO container_size (container_volume, container_measure_id, description) VALUES (18,2,'kilderkin'); 
INSERT INTO container_size (container_volume, container_measure_id, description) VALUES (22,2,'22 gallon'); 
INSERT INTO container_size (container_volume, container_measure_id, description) VALUES (36,2,'barrel'); 


-- ------------------------------------------------------------
-- Table structure for table `product_style`
-- Complex table to allow us to store many different types of product style
-- agant a product category. Examples are for a product_category of 'beer'
-- to have product_styles of 'IPA','Porter','Mild' etc
-- ------------------------------------------------------------

CREATE TABLE product_style (
  product_style_id INTEGER(6) NOT NULL AUTO_INCREMENT,
  product_category_id INTEGER(6) NOT NULL,
  description VARCHAR(100) NOT NULL,
  PRIMARY KEY(product_style_id),
  UNIQUE KEY(product_category_id, description),
  INDEX IDX_PS_pcid(product_category_id),
  FOREIGN KEY FK_PS_pcid_PC_pcid(product_category_id)
    REFERENCES product_category(product_category_id)
      ON DELETE RESTRICT
      ON UPDATE RESTRICT
)
TYPE=InnoDB DEFAULT CHARSET=utf8;


INSERT INTO product_style (product_category_id,description) VALUES ((SELECT product_category_id FROM product_category WHERE description = 'beer'), 'Mild');
INSERT INTO product_style (product_category_id,description) VALUES ((SELECT product_category_id FROM product_category WHERE description = 'beer'), 'Bitter');
INSERT INTO product_style (product_category_id,description) VALUES ((SELECT product_category_id FROM product_category WHERE description = 'beer'), 'Golden Ale');
INSERT INTO product_style (product_category_id,description) VALUES ((SELECT product_category_id FROM product_category WHERE description = 'beer'), 'Pale Ale');
INSERT INTO product_style (product_category_id,description) VALUES ((SELECT product_category_id FROM product_category WHERE description = 'beer'), 'IPA');
INSERT INTO product_style (product_category_id,description) VALUES ((SELECT product_category_id FROM product_category WHERE description = 'beer'), 'Porter');
INSERT INTO product_style (product_category_id,description) VALUES ((SELECT product_category_id FROM product_category WHERE description = 'beer'), 'Stout');
INSERT INTO product_style (product_category_id,description) VALUES ((SELECT product_category_id FROM product_category WHERE description = 'beer'), 'Barley Wine');
INSERT INTO product_style (product_category_id,description) VALUES ((SELECT product_category_id FROM product_category WHERE description = 'beer'), 'Old Ale');
INSERT INTO product_style (product_category_id,description) VALUES ((SELECT product_category_id FROM product_category WHERE description = 'beer'), 'Scottish Beer');
INSERT INTO product_style (product_category_id,description) VALUES ((SELECT product_category_id FROM product_category WHERE description = 'beer'), 'Light Bitter');


INSERT INTO product_style (product_category_id,description) VALUES ((SELECT product_category_id FROM product_category WHERE description = 'cider'), 'very dry');
INSERT INTO product_style (product_category_id,description) VALUES ((SELECT product_category_id FROM product_category WHERE description = 'cider'), 'dry');
INSERT INTO product_style (product_category_id,description) VALUES ((SELECT product_category_id FROM product_category WHERE description = 'cider'), 'medium dry');
INSERT INTO product_style (product_category_id,description) VALUES ((SELECT product_category_id FROM product_category WHERE description = 'cider'), 'medium');
INSERT INTO product_style (product_category_id,description) VALUES ((SELECT product_category_id FROM product_category WHERE description = 'cider'), 'sweet');
INSERT INTO product_style (product_category_id,description) VALUES ((SELECT product_category_id FROM product_category WHERE description = 'cider'), 'medium sweet');
INSERT INTO product_style (product_category_id,description) VALUES ((SELECT product_category_id FROM product_category WHERE description = 'cider'), 'very sweet');


-- ------------------------------------------------------------
-- Table structure for table `sale_volume`
-- Simple table to store the type of volume that we sell liquid products in.
-- These would typically be 'pint','half pint','small wine','large wine' all
-- volumes are stored as integers expected to be ml as these can be converted
-- to other units.
-- 
-- REQUIRES SOME MORE THOUGHT
-- ------------------------------------------------------------

CREATE TABLE sale_volume (
  sale_volume_id INTEGER(6) NOT NULL AUTO_INCREMENT,
  container_measure_id INTEGER(6) NOT NULL,
  description VARCHAR(30) NOT NULL,
  volume DECIMAL(4,2) NULL,
  PRIMARY KEY(sale_volume_id),
  UNIQUE KEY(description),
  FOREIGN KEY FK_SV_cmid_CM_cmid(container_measure_id)
    REFERENCES container_measure(container_measure_id)
      ON DELETE RESTRICT
      ON UPDATE NO ACTION
)
TYPE=InnoDB DEFAULT CHARSET=utf8;

-- ------------------------------------------------------------
-- Table structure for table `contact`
-- Complex table building contact, at present contains only name (first name,
-- last name, address, post code, country and the type of contact it is) it 
-- could contain a more complex address and title of the person. Does not 
-- contain a telephone as this is covered by contact_telephone. 
-- ------------------------------------------------------------

CREATE TABLE contact (
  contact_id INTEGER(6) NOT NULL AUTO_INCREMENT,
  company_id INTEGER(6) NOT NULL,
  contact_type_id INTEGER(6) NOT NULL,
  last_name VARCHAR(100) NULL,
  first_name VARCHAR(100) NULL,
  street_address TEXT NULL,
  postcode VARCHAR(20) NULL,
  email VARCHAR(100) NULL,
  country_id INTEGER(6) NULL,
  comment TEXT NULL,
  PRIMARY KEY(contact_id),
  UNIQUE KEY(company_id, contact_type_id),
  INDEX IDX_CNT_cc2(country_id),
  INDEX IDX_CNT_cnttyid(contact_type_id),
  FOREIGN KEY FK_CON_coid_DMPcoid(company_id)
    REFERENCES company(company_id)
      ON DELETE RESTRICT
      ON UPDATE NO ACTION,
  FOREIGN KEY FK_CON_cntid_CTPY_ctid(contact_type_id)
    REFERENCES contact_type(contact_type_id)
      ON DELETE RESTRICT
      ON UPDATE NO ACTION,
  FOREIGN KEY FK_CON_ccode_CNTRY_ccode(country_id)
    REFERENCES country(country_id)
      ON DELETE RESTRICT
      ON UPDATE NO ACTION
)
TYPE=InnoDB DEFAULT CHARSET=utf8;

-- ------------------------------------------------------------
-- Table structure for table `telephone`
-- Simple table to store all the elements that make up a telephone number
-- the interational code, area_code,telephone and extenstion
-- ------------------------------------------------------------

CREATE TABLE telephone (
  telephone_id INTEGER(6) NOT NULL AUTO_INCREMENT,
  telephone_type_id INTEGER(6) NULL,
  contact_id INTEGER(6) NOT NULL,
  international_code VARCHAR(10) NULL,
  area_code VARCHAR(10) NULL,
  local_number VARCHAR(50) NOT NULL,
  extension VARCHAR(10) NULL,
  PRIMARY KEY(telephone_id),
  INDEX IDX_TEL_ttid(telephone_type_id),
  INDEX IDX_TEL_cntid(contact_id),
  FOREIGN KEY FK_TEL_cntid_CT_cntid(contact_id)
    REFERENCES contact(contact_id)
      ON DELETE RESTRICT
      ON UPDATE NO ACTION,
  FOREIGN KEY FK_TEL_ttid_TT_ttid(telephone_type_id)
    REFERENCES telephone_type(telephone_type_id)
      ON DELETE RESTRICT
      ON UPDATE NO ACTION
)
TYPE=InnoDB DEFAULT CHARSET=utf8;

-- ------------------------------------------------------------
-- Table structure for table `festival_entry`
-- Complex table referencing both the fesitival_opening and the 
-- festival_entry_type (as the primary key) so that each festival opening
-- and festival entry type can be charged a different amount in a single 
-- currency, does not support multi-currency at present.
-- ------------------------------------------------------------

CREATE TABLE festival_entry (
  festival_opening_id INTEGER(6) NOT NULL AUTO_INCREMENT,
  festival_entry_type_id INTEGER(6) NOT NULL,
  currency_id INT(6) NOT NULL,
  price INTEGER(11) UNSIGNED NOT NULL,
  PRIMARY KEY(festival_opening_id, festival_entry_type_id),
  FOREIGN KEY FK_FE_fo_FO_fo(festival_opening_id)
    REFERENCES festival_opening(festival_opening_id)
      ON DELETE RESTRICT
      ON UPDATE NO ACTION,
  FOREIGN KEY FK_FE_fet_FET_fet(festival_entry_type_id)
    REFERENCES festival_entry_type(festival_entry_type_id)
      ON DELETE RESTRICT
      ON UPDATE NO ACTION,
  FOREIGN KEY FK_FE_cc_CUR_cc(currency_id)
    REFERENCES currency(currency_id)
      ON DELETE RESTRICT
      ON UPDATE NO ACTION
)
TYPE=InnoDB DEFAULT CHARSET=utf8;

-- ------------------------------------------------------------
-- Table structure for table `product`
-- Contains a product id that is auto generated, a name, decription and
-- a product style id, from this the product type can be deduced. There is
-- a comment to allow a fuller description of the product.
-- ------------------------------------------------------------

CREATE TABLE product (
  product_id INTEGER(6) NOT NULL AUTO_INCREMENT,
  company_id INTEGER(6) NOT NULL,
  name VARCHAR(100) NOT NULL,
  product_category_id INTEGER(6) NOT NULL,
  product_style_id INTEGER(6) NULL,
  nominal_abv DECIMAL(3,1) NULL,
  description TEXT NULL,
  comment TEXT NULL,
  PRIMARY KEY(product_id),
  UNIQUE KEY (company_id, name),
  INDEX IDX_pdc_pcid(product_category_id),
  INDEX IDX_pdc_psid(product_style_id),
  FOREIGN KEY FK_PDCT_compid_COMP_compid(company_id)
    REFERENCES company(company_id)
      ON DELETE CASCADE
      ON UPDATE NO ACTION,
  FOREIGN KEY FK_PDCT_pc_PC_pc(product_category_id)
    REFERENCES product_category(product_category_id)
      ON DELETE RESTRICT
      ON UPDATE NO ACTION,
  FOREIGN KEY FK_PDCT_ps_PS_ps(product_style_id)
    REFERENCES product_style(product_style_id)
      ON DELETE RESTRICT
      ON UPDATE NO ACTION
)
TYPE=InnoDB DEFAULT CHARSET=utf8;

-- ------------------------------------------------------------
-- Table structure for table `festival_product`
-- Linking table used to track the products being ordered for the festival, in the absence of information about gyles and casks. Note that a trigger is used to maintain relational consistency.
-- ------------------------------------------------------------

CREATE TABLE festival_product (
  festival_product_id INTEGER(6) NOT NULL AUTO_INCREMENT,
  festival_id INTEGER(6) NOT NULL,
  sale_volume_id INTEGER(6) NOT NULL,
  sale_currency_id INTEGER(6) NOT NULL,
  sale_price INTEGER(11) UNSIGNED NULL,
  product_id INTEGER(6) NOT NULL,
  comment TEXT default NULL,
  PRIMARY KEY `fp_key` (festival_product_id),
  UNIQUE KEY (festival_id, product_id),
  FOREIGN KEY FK_FP_festid_FEST_festid(festival_id)
    REFERENCES festival(festival_id)
      ON DELETE CASCADE
      ON UPDATE NO ACTION,
  FOREIGN KEY FK_FP_prodid_PROD_prodid(product_id)
    REFERENCES product(product_id)
      ON DELETE CASCADE
      ON UPDATE NO ACTION,
  INDEX IDX_PDCT_svid(sale_volume_id),
  FOREIGN KEY FK_PDCT_svid_SV_svid(sale_volume_id)
    REFERENCES sale_volume(sale_volume_id)
      ON DELETE RESTRICT
      ON UPDATE NO ACTION,
  FOREIGN KEY FK_PDCT_slccode_CUR_ccode(sale_currency_id)
    REFERENCES currency(currency_id)
      ON DELETE RESTRICT
      ON UPDATE NO ACTION
)
TYPE=InnoDB DEFAULT CHARSET=utf8;  

-- ------------------------------------------------------------
-- For each product, there can be multiple characteristics
-- ------------------------------------------------------------

CREATE TABLE product_characteristic (
  product_id INTEGER(6) NOT NULL,
  product_characteristic_type_id INTEGER(6) NOT NULL,
  value INTEGER(11) UNSIGNED NULL,
  PRIMARY KEY(product_id),
  FOREIGN KEY Rel_29(product_characteristic_type_id)
    REFERENCES product_characteristic_type(product_characteristic_type_id)
      ON DELETE RESTRICT
      ON UPDATE NO ACTION,
  FOREIGN KEY FK_PDCT_pdid_PC_pid(product_id)
    REFERENCES product(product_id)
      ON DELETE RESTRICT
      ON UPDATE NO ACTION
)
TYPE=InnoDB DEFAULT CHARSET=utf8;

-- ------------------------------------------------------------
-- Table structure for table `brew_batch`
-- Complex table, that stores details of a particular brew batch of a 
-- beer production run. Each brew batch has a brewery that is the company that
-- the beer is associated with and a brewer that is a contact of the 
-- individual that brewed the beer, if the beer is brewed outside the 
-- actual brewery the company that actually brewed the beer can be traced
-- through the company contact provided that there is a link there.
--
-- Addendum: This table now references festival_product instead of
-- product. This is conceptually flawed in that now each gyle is
-- assumed to exist at a single festival only, but it does make
-- automated management of gyles much simpler. If this
-- oversimplification ever becomes an issue then one way to resolve
-- this would be to rename this table "festival_gyle", and have it
-- link out to a separate gyle table containing abv,
-- external_reference and the like. The only downside of doing that,
-- and indeed of leaving this as an abstract concept table related
-- directly to product, is that at some point it forces the user to
-- either (a) actively manage gyle information, or (b) completely
-- disregard it. In most cases forcing this choice on users will be
-- undesirable.
-- ------------------------------------------------------------

CREATE TABLE gyle (
  gyle_id INTEGER(6) NOT NULL AUTO_INCREMENT,
  company_id INTEGER(6) NOT NULL,
  festival_product_id INTEGER(6) NOT NULL,
  abv DECIMAL(3,1) NULL,
  comment TEXT NULL,
  external_reference VARCHAR(255) NULL,
  internal_reference VARCHAR(255) NOT NULL,
  PRIMARY KEY(gyle_id),
  UNIQUE KEY(festival_product_id, internal_reference),
  INDEX IDX_BB_bcpnyid(company_id),
  INDEX IDX_BB_bpid(festival_product_id),
  INDEX IDX_BB_eref(external_reference),
  INDEX IDX_BB_iref(internal_reference),
  FOREIGN KEY FK_BB_coid_COMP_coid(company_id)
    REFERENCES company(company_id)
      ON DELETE RESTRICT
      ON UPDATE NO ACTION,
  FOREIGN KEY FK_PDCT_prdid_BB_prdid(festival_product_id)
    REFERENCES festival_product(festival_product_id)
      ON DELETE RESTRICT
      ON UPDATE NO ACTION
)
TYPE=InnoDB DEFAULT CHARSET=utf8;

-- ------------------------------------------------------------
-- Table structure for table `cask`

-- Complex table that stores individual casks that we receive. Each
-- cask comes from a a single brew batch. Because they can be
-- delivered from different sources the distribution company is stored
-- here. Each cask is only used at one festival and is only ever
-- tapped at one bar, although this may not be known at the time of
-- delivery so this may have to be taken into account.  The
-- stillage<x,y,z>location is an indication of where the cask is
-- actually placed in the 3D world of the stillageing. The stillage
-- location is the physical location of the stillage itself, this may
-- be 'main tent', 'staff tent','igloo' etc. The stillage bay is a
-- simple bay number which can be used as needed.
-- ------------------------------------------------------------

CREATE TABLE cask (
  cask_id INTEGER(6) NOT NULL AUTO_INCREMENT,
  festival_id INTEGER(6) NOT NULL,
  gyle_id INTEGER(6) NOT NULL,
  distributor_company_id INTEGER(6) NULL,
  container_size_id INTEGER(6) NOT NULL,
  bar_id INTEGER(6) NULL,
  currency_id INTEGER(6) NOT NULL,
  price INTEGER(11) UNSIGNED NULL,
  stillage_location_id INTEGER(6) NULL,
  stillage_bay INTEGER(4) UNSIGNED NULL,
  stillage_x_location INTEGER(6) UNSIGNED NULL,
  stillage_y_location INTEGER(6) UNSIGNED NULL,
  stillage_z_location INTEGER(6) UNSIGNED NULL,
  comment TEXT NULL,
  external_reference VARCHAR(255) NULL,
  internal_reference VARCHAR(255) NULL,
  cellar_reference VARCHAR(255) NULL,
  is_vented TINYINT(1) NULL,
  is_tapped TINYINT(1) NULL,
  is_ready TINYINT(1) NULL,
  is_condemned TINYINT(1) NULL,
  PRIMARY KEY(cask_id),
  UNIQUE KEY `festival_gyle_cask` (festival_id, gyle_id, internal_reference),
  UNIQUE KEY `festival_cellar_ref` (festival_id, cellar_reference),
  INDEX FK_CSK_bbid(gyle_id),
  INDEX FK_CSK_dcid(distributor_company_id),
  INDEX FK_CSK_bid(bar_id),
  INDEX FK_CSK_stid(stillage_location_id),
  INDEX FK_CSK_csid_CS_csid(container_size_id),
  INDEX FK_CSK_cc3_CUR_cc3(currency_id),
  INDEX IDX_CSK_exref(external_reference),
  INDEX IDX_CSK_iref(internal_reference),
  FOREIGN KEY FK_CSK_bid_BR_bid(bar_id)
    REFERENCES bar(bar_id)
      ON DELETE RESTRICT
      ON UPDATE NO ACTION,
  FOREIGN KEY FK_CSK_csid_CS_csid(container_size_id)
    REFERENCES container_size(container_size_id)
      ON DELETE RESTRICT
      ON UPDATE NO ACTION,
  FOREIGN KEY FK_CSK_fstId_FST_fstid(festival_id)
    REFERENCES festival(festival_id)
      ON DELETE RESTRICT
      ON UPDATE NO ACTION,
  FOREIGN KEY FK_CSK_dcId_COMP_coid(distributor_company_id)
    REFERENCES company(company_id)
      ON DELETE RESTRICT
      ON UPDATE NO ACTION,
  FOREIGN KEY FK_CSK_curcd_CUR_curcd(currency_id)
    REFERENCES currency(currency_id)
      ON DELETE RESTRICT
      ON UPDATE NO ACTION,
  FOREIGN KEY FK_CSK_gyleid_GYLE_gyleid(gyle_id)
    REFERENCES gyle(gyle_id)
      ON DELETE RESTRICT
      ON UPDATE NO ACTION,
  FOREIGN KEY FK_CSK_locid_STILLOC_locid(stillage_location_id)
    REFERENCES stillage_location(stillage_location_id)
      ON DELETE RESTRICT
      ON UPDATE NO ACTION
)
TYPE=InnoDB DEFAULT CHARSET=utf8;

-- ------------------------------------------------------------
-- Table structure for table `cask_measure`
-- Complex table to store the volume in a cask at different points in time
-- along with a comment.
-- All measurments stored as ml converted for representation to users?
-- 'date' is a nominal date for reference such as the date and time that the
-- row was inserted into the table, should be editable
-- 'start_date' and 'end_date' are the date/time that the reading actually 
-- covers, it would normally be that the 'end_date' is the same as the next
-- -- 'start_date' for that cask but that is not guaranteed.
-- ------------------------------------------------------------

CREATE TABLE cask_measurement (
  cask_measurement_id INTEGER(6) NOT NULL AUTO_INCREMENT,
  cask_id INTEGER(6) NOT NULL,
  date DATETIME NULL,
  start_date DATETIME NULL,
  end_date DATETIME NULL,
  volume decimal(5,2) NOT NULL,
  container_measure_id INTEGER(6) NOT NULL,
  comment TEXT NULL,
  PRIMARY KEY(cask_measurement_id),
  INDEX IDX_CM_cid(cask_id),
  FOREIGN KEY FK_CSKM_cskid_CSK_cskid(cask_id)
    REFERENCES cask(cask_id)
      ON DELETE RESTRICT
      ON UPDATE NO ACTION,
  FOREIGN KEY FK_CSKM_cskid_CM_cmid(container_measure_id)
    REFERENCES container_measure(container_measure_id)
      ON DELETE RESTRICT
      ON UPDATE NO ACTION
)
TYPE=InnoDB DEFAULT CHARSET=utf8;

-- ------------------------------------------------------------
-- Table structure for table `order_batch`
-- Stores the information used to track batches of product orders, so
-- that we can track primary orders vs. reorders.
-- ------------------------------------------------------------

CREATE TABLE order_batch (
  order_batch_id INTEGER(6) NOT NULL AUTO_INCREMENT,
  festival_id INTEGER(6) NOT NULL,
  description VARCHAR(255) NOT NULL,
  order_date DATE NULL,
  PRIMARY KEY(order_batch_id),
  UNIQUE KEY `festival_order_batch` (festival_id, description),
  INDEX FK_ORDER_fid(festival_id),
  FOREIGN KEY FK_ORDER_fid_FEST_fid(festival_id)
    REFERENCES festival(festival_id)
      ON DELETE RESTRICT
      ON UPDATE NO ACTION
)
TYPE=InnoDB DEFAULT CHARSET=utf8;

-- ------------------------------------------------------------
-- Table structure for table `product_order`
-- Stores the information used to create an outgoing set of orders prior to the festival.
-- This is designed to be a work-in-progress style table, with a flag indicating finalised details.
-- ------------------------------------------------------------

CREATE TABLE product_order (
  product_order_id INTEGER(6) NOT NULL AUTO_INCREMENT,
  order_batch_id INTEGER(6) NOT NULL,
  product_id INTEGER(6) NOT NULL,
  distributor_company_id INTEGER(6) NOT NULL,
  container_size_id INTEGER(6) NOT NULL,
  cask_count INTEGER UNSIGNED NULL,
  currency_id INTEGER(6) NOT NULL,
  advertised_price INTEGER UNSIGNED NULL,
  is_final TINYINT(1) NULL,
  is_received TINYINT(1) NULL,
  comment TEXT NULL,
  PRIMARY KEY(product_order_id),
  UNIQUE KEY `product_order_batch` (order_batch_id, product_id, distributor_company_id,
                                       container_size_id, cask_count),
  INDEX FK_ORDER_fid(order_batch_id),
  INDEX FK_ORDER_pid(product_id),
  INDEX FK_ORDER_dcid(distributor_company_id),
  INDEX FK_ORDER_cc3_CUR_cc3(currency_id),
  INDEX FK_ORDER_csid_CS_csid(container_size_id),
  FOREIGN KEY FK_ORDER_fid_BATCH_fid(order_batch_id)
    REFERENCES order_batch(order_batch_id)
      ON DELETE RESTRICT
      ON UPDATE NO ACTION,
  FOREIGN KEY FK_ORDER_pid_PROD_pid(product_id)
    REFERENCES product(product_id)
      ON DELETE RESTRICT
      ON UPDATE NO ACTION,
  FOREIGN KEY FK_ORDER_did_COMP_cid(distributor_company_id)
    REFERENCES company(company_id)
      ON DELETE RESTRICT
      ON UPDATE NO ACTION,
  FOREIGN KEY FK_ORDER_curcd_CUR_curcd(currency_id)
    REFERENCES currency(currency_id)
      ON DELETE RESTRICT
      ON UPDATE NO ACTION,
  FOREIGN KEY FK_ORDER_csid_CS_csid(container_size_id)
    REFERENCES container_size(container_size_id)
      ON DELETE RESTRICT
      ON UPDATE NO ACTION
)
TYPE=InnoDB DEFAULT CHARSET=utf8;

-- Create some basic triggers to make sure that product_style and
-- product_characteristic usage is properly constrained to their
-- respective product_categories. These triggers are perhaps a little
-- lame, but are apparently the best that MySQL version 5.0 can
-- muster. Fix the 'set' statements to proper error raising when MySQL
-- 6.1 is finally available.

delimiter //

-- Product
drop trigger if exists `product_insert_trigger`//
create trigger `product_insert_trigger`
    before insert on product
for each row
begin
    -- check that the style is valid
    if ( new.product_style_id is not null
       and (select count(product_style_id)
            from product_style
            where product_category_id=new.product_category_id
            and product_style_id=new.product_style_id) = 0 ) then
        call ERROR_PRODUCT_INSERT_TRIGGER();
    end if;
end;
//

drop trigger if exists `product_update_trigger`//
create trigger `product_update_trigger`
    before update on product
for each row
begin
    -- check that the style is valid
    if ( new.product_style_id is not null
        and (select count(product_style_id)
             from product_style
             where product_category_id=new.product_category_id
             and product_style_id=new.product_style_id) = 0 ) then
        call ERROR_PRODUCT_UPDATE_TRIGGER();
    end if;
    -- check for inequality between number of types present and number of valid types present.
    if ( (select count(t.product_characteristic_type_id)
          from product_characteristic t
          where t.product_id=new.product_id)
          !=
         (select count(t.product_characteristic_type_id)
          from product_characteristic_type t, product_characteristic c
          where c.product_id=new.product_id
          and t.product_characteristic_type_id=c.product_characteristic_type_id
          and t.product_category_id=new.product_category_id) ) then
        call ERROR_PRODUCT_UPDATE_TRIGGER();
    end if;
end;
//

-- Product style
drop trigger if exists `product_style_update_trigger`//
create trigger `product_style_update_trigger`
    before update on product_style
for each row
begin
    -- if we're changing category association, ensure we haven't already used this style.
    if ( old.product_category_id != new.product_category_id
         and (select count(p.product_style_id)
              from product p
              where p.product_style_id=old.product_style_id) > 0 ) then
        call ERROR_PRODUCT_STYLE_UPDATE_TRIGGER();
    end if;
end;
//

-- Product characteristic type
drop trigger if exists `product_characteristic_type_update_trigger`//
create trigger `product_characteristic_type_update_trigger`
    before update on product_characteristic_type
for each row
begin
    -- if we're changing category association, ensure we haven't already used this type.
    if ( old.product_category_id != new.product_category_id
         and (select count(c.product_characteristic_type_id)
              from product_characteristic c
              where c.product_characteristic_type_id=old.product_characteristic_type_id) > 0 ) then
        call ERROR_PRODUCT_CHARACTERISTIC_TYPE_UPDATE_TRIGGER();
    end if;
end;
//

-- Product characteristic
drop trigger if exists `product_characteristic_insert_trigger`//
create trigger `product_characteristic_insert_trigger`
    before insert on product_characteristic
for each row
begin
    -- check that the characteristic type is valid
    if ( (select count(t.product_characteristic_type_id)
          from product_characteristic_type t, product p
          where t.product_characteristic_type_id=new.product_characteristic_type_id
          and p.product_id=new.product_id
          and t.product_category_id=p.product_category_id) = 0 ) then
        call ERROR_PRODUCT_CHARACTERISTIC_INSERT_TRIGGER();
    end if;
end;
//

drop trigger if exists `product_characteristic_update_trigger`//
create trigger `product_characteristic_update_trigger`
    before update on product_characteristic
for each row
begin
    -- check that the characteristic type is valid
    if ( (select count(t.product_characteristic_type_id)
          from product_characteristic_type t, product p
          where t.product_characteristic_type_id=new.product_characteristic_type_id
          and p.product_id=new.product_id
          and t.product_category_id=p.product_category_id) = 0 ) then
        call ERROR_PRODUCT_CHARACTERISTIC_UPDATE_TRIGGER();
    end if;
end;
//

-- Festival to Product to Cask

-- Check inserts, updates on cask table (note that we also check updates on Gyle below).
drop trigger if exists `cask_insert_trigger`//
create trigger `cask_insert_trigger`
    before insert on cask
for each row
begin
    if ( (select count(fp.festival_id)
            from festival_product fp, gyle g
            where new.gyle_id=g.gyle_id
            and g.festival_product_id=fp.festival_product_id
            and fp.festival_id=new.festival_id) = 0 ) then
        call ERROR_CASK_INSERT_TRIGGER();
    end if;
end;
//

drop trigger if exists `cask_update_trigger`//
create trigger `cask_update_trigger`
    before update on cask
for each row
begin
    if ( (select count(fp.festival_id)
            from festival_product fp, gyle g
            where new.gyle_id=g.gyle_id
            and g.festival_product_id=fp.festival_product_id
            and fp.festival_id=new.festival_id) = 0 ) then
        call ERROR_CASK_UPDATE_TRIGGER();
    end if;
end;
//

-- Maintain our linking table.
drop trigger if exists `festival_product_delete_trigger`//
create trigger `festival_product_delete_trigger`
    before delete on festival_product
for each row
begin
    if ( (select count(festival_id)
          from cask c, gyle g
          where c.gyle_id=g.gyle_id
          and g.festival_product_id=old.festival_product_id
          and c.festival_id=old.festival_id) != 0 ) then
        call ERROR_CASK_DELETE_TRIGGER();
    end if;
end;
//

-- Product to Gyle (N.B. gyle.company_id is not necessarily expected
-- to agree with product.company_id).

drop trigger if exists `gyle_update_trigger`//
create trigger `gyle_update_trigger`
    before update on gyle
for each row
begin
    -- carried over from the festival_product link above.
    if ( (select count(fp.festival_id)
            from festival_product fp, cask c, gyle g
            where new.gyle_id=c.gyle_id
            and g.festival_product_id=fp.festival_product_id
            and fp.festival_id=c.festival_id) = 0 ) then
        call ERROR_CASK_UPDATE_FP_TRIGGER();
    end if;
end;
//

-- Maintain our linking table.
drop trigger if exists `festival_product_delete_trigger`//
create trigger `festival_product_delete_trigger`
    before delete on festival_product
for each row
begin
    if ( (select count(festival_id)
          from gyle g, cask c
          where g.festival_product_id=old.festival_product_id
          and g.gyle_id=c.gyle_id
          and c.festival_id=old.festival_id) != 0 ) then
        call ERROR_GYLE_DELETE_TRIGGER();
    end if;
end;
//

-- End of triggers
delimiter ;
