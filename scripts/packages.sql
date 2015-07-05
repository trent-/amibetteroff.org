create or replace package taxation_income_api
as

    type t_state_avg_income is record (
        area_code varchar2(20),
        avg_income NUMBER
    );

    function get_industry_gender_max(
        p_industry_code in industry_codes.industry_code%type
      , p_gender in varchar2
    ) return t_state_avg_income;

    function get_industry_gender_min(
        p_industry_code in industry_codes.industry_code%type
      , p_gender in varchar2
    ) return t_state_avg_income;


end taxation_income_api;
/

create or replace package body taxation_income_api
as

    function get_industry_gender_max(
        p_industry_code in industry_codes.industry_code%type
      , p_gender in varchar2
    ) return t_state_avg_income
    as

        l_max_income t_state_avg_income;

    begin

        with tax_income as (
            select coalesce(area_code, 'Unknown') area_code, total_tax_dollars/num_people avg_income
            from taxation_income
            where industry_code = p_industry_code
            and gender = p_gender
        ), ranked_avgs as (
            select area_code, avg_income, row_number() over (order by avg_income desc) rn
            from tax_income
        )
        select area_code, avg_income
        into l_max_income
        from ranked_avgs
        where rn = 1;

        return l_max_income;
    exception
    when no_data_found
    then
        l_max_income.area_code := NULL;
        l_max_income.avg_income := NULL;
        --return an empty record
        return l_max_income;

    end get_industry_gender_max;

    function get_industry_gender_min(
        p_industry_code in industry_codes.industry_code%type
      , p_gender in varchar2
    ) return t_state_avg_income
    as

        l_max_income t_state_avg_income;

    begin
        with tax_income as (
            select coalesce(area_code, 'Unknown') area_code, total_tax_dollars/num_people avg_income
            from taxation_income
            where industry_code = p_industry_code
            and gender = p_gender
        ), ranked_avgs as (
            select area_code, avg_income, row_number() over (order by avg_income) rn
            from tax_income
        )
        select area_code, avg_income
        into l_max_income
        from ranked_avgs
        where rn = 1;

        return l_max_income;
    exception
    when no_data_found
    then
        l_max_income.area_code := NULL;
        l_max_income.avg_income := NULL;
        --return an empty record
        return l_max_income;
    end get_industry_gender_min;


end taxation_income_api;
/
