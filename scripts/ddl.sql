create table tax_year_people(
    ID NUMBER PRIMARY KEY,
    YEAR_END NUMBER(4) NOT NULL,
    NUM_PEOPLE NUMBER NOT NULL
);
/

create sequence tax_year_people_seq;
/

create or replace trigger bi_tax_year_people
before insert on tax_year_people
for each row
begin
    :NEW.ID := tax_year_people_seq.nextval;
end bi_tax_year_people;
/


create table tax_state_people(
    ID NUMBER PRIMARY KEY,
    YEAR_END NUMBER(4) NOT NULL,
    AUS_STATE VARCHAR2(3),
    TAXED_PEOPLE NUMBER NOT NULL
);
/

create sequence tax_state_people_seq;
/

create or replace trigger bi_tax_state_people
before insert on tax_state_people
for each row
begin
    :NEW.ID := tax_state_people_seq.nextval;
end bi_tax_state_people;
/


alter table tax_State_people
add constraint "TAX_STATE_PEOPLE_UK1" UNIQUE ("YEAR_END", "AUS_STATE");
/


create table tax_brackets(
    ID NUMBER PRIMARY KEY,
    start_amount NUMBER NOT NULL,
    end_amount NUMBER
);
/

create sequence tax_brackets_seq;
/

create or replace trigger bi_tax_brackets
before insert on tax_brackets
for each row
begin
    :NEW.ID := tax_brackets_seq.nextval;
end bi_tax_brackets;
/


alter table tax_brackets
add constraint "TAX_BRACKETS_UK1" UNIQUE (start_amount, end_amount);
/




create table industry_codes(
    ID NUMBER PRIMARY KEY,
    INDUSTRY_CODE VARCHAR2(1) NOT NULL,
    INDUSTRY_NAME VARCHAR2(50) NOT NULL
);
/

create sequence industry_codes_seq;
/

create or replace trigger bi_industry_codes
before insert on industry_codes
for each row
begin
    :NEW.id := industry_codes_seq.nextval;
end bi_industry_codes_seq;
/


alter table industry_codes
add constraint "INDUSTRY_CODES_UK1" UNIQUE ("INDUSTRY_CODE");
/

create table area (
    ID NUMBER PRIMARY KEY,
    AREA_CODE VARCHAR2(3) NOT NULL,
    AREA_NAME VARCHAR2(15) NOT NULL
);
/

create sequence area_seq;
/

create or replace trigger bi_area
before insert on area
for each row
begin
    :NEW.ID := area_seq.nextval;
end bi_area;
/

alter table area
add constraint "AREA_UK1" UNIQUE ("AREA_CODE");
/


create table taxation_income (
    ID NUMBER PRIMARY KEY,
    AREA_CODE VARCHAR2(3),
    GENDER varchar2(6) NOT NULL,
    INDUSTRY_CODE varchar2(1) NOT NULL,
    NUM_PEOPLE NUMBER NOT NULL,
    TOTAL_TAX_DOLLARS NUMBER NOT NULL,
    GROSS_TAX_DOLLARS NUMBER NOT NULL,
    NET_TAX_DOLLARS NUMBER NOT NULL
);
/

create sequence taxation_income_seq;
/

create or replace trigger bi_taxation_income
before insert on taxation_income
for each row
begin
    :NEW.ID := taxation_income_seq.nextval;
end bi_taxation_income;
/

alter table taxation_income
add constraint "TAXATION_INCOME_FK1" FOREIGN KEY ("AREA_CODE") REFERENCES "AREA" ("AREA_CODE");
/

alter table taxation_income
add constraint "INDUSTRY_CODE_FK2" FOREIGN KEY ("INDUSTRY_CODE") REFERENCES "INDUSTRY_CODES" ("INDUSTRY_CODE");
/

CREATE OR REPLACE TRIGGER "BI_TAXATION_INCOME"
before insert on taxation_income
for each row
begin
  :NEW.ID := taxation_income_seq.nextval;
end bi_taxation_income;
/
ALTER TRIGGER "BI_TAXATION_INCOME" ENABLE;
/

--

create table state_expenditure(
    ID NUMBER PRIMARY KEY,
    STATE VARCHAR2(3) NOT NULL,
    CATEGORY varchar2(26) NOT NULL,
    WEEKLY_SPEND NUMBER
);
/


create sequence state_expenditure_seq;
    /


    CREATE OR REPLACE TRIGGER "BI_STATE_EXPENDITURE"
    before insert on STATE_EXPENDITURE
    for each row
    begin
      :NEW.ID := state_expenditure_seq.nextval;
    end BI_STATE_EXPENDITURE;
    /


create table mean_house_prices(
    ID NUMBER PRIMARY KEY,
    "QUARTER" VARCHAR2(26 BYTE),
	"STATE" VARCHAR2(3 BYTE),
	"YEAR" NUMBER,
	"MEAN_PRICE" NUMBER
);
/

create sequence mean_house_prices_seq;
    /

    CREATE OR REPLACE TRIGGER "BI_MEAN_HOUSE_PRICES"
    before insert on MEAN_HOUSE_PRICES
    for each row
    begin
      :NEW.ID := mean_house_prices_seq.nextval;
    end BI_MEAN_HOUSE_PRICES;
    /



    create or replace view v_current_mean_price as
    with mean_prices as (
    select state, case quarter when 'JUN' then 1 when 'SEPT' then 2 when 'DEC' then 3 when 'MAR' then 4 else 5 end ordered_quarter, year, mean_price
    from mean_house_prices
    ),
    ranked_prices as (
    select state, year, mean_price, row_number() over (partition by state order by year desc, ordered_quarter asc) rn
    from mean_prices
    )
    select state, mean_price
    from ranked_prices
    where rn = 1;
    /
