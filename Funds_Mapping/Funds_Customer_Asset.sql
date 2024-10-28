-- fund_id, asset_class_id, available_amount
create or replace view v_asset_pool_per_fund as (
with customer_set as (
select customer_id, fund_id from customer_segment cs 
join fund_stats fs on cs.segment_id = fs.segment_id)
SELECT 
    fund_id,
    ao.asset_class_id, 
    sum(total * ao.allocation_perc / 100) AS available_amount
FROM customer_assets ca 
INNER JOIN customer_set cs on 
    cs.customer_id = ca.customer_id
INNER JOIN asset_objective_class_allocation ao 
    ON ao.asset_objective_id = ca.asset_objective_id
group by fund_id, asset_class_id);

select * from fund_assets where fund_id = 9;

drop table fund_assets;

select * from v_asset_pool_per_fund;

-- fund_id, total_asset_available
create or replace view fund_max_asset as (
WITH fund_asset_class_allocation AS (
    SELECT 
        fa.fund_id, 
        fa.asset_class_id, 
        ppf.available_amount as available_amount, 
        fa.percent_of_fund, 
        max_feasible_aum
    FROM v_asset_pool_per_fund ppf
    INNER JOIN fund_assets fa 
        ON ppf.fund_id = fa.fund_id 
        AND ppf.asset_class_id = fa.asset_class_id
)
SELECT 
    fund_id, 
    SUM(available_amount) AS total_asset_available,
    SUM(max_feasible_aum) as max_feasible_aum,
    
FROM fund_asset_class_allocation 
GROUP BY fund_id);

select * , max_feasible_aum/total_asset_available*100 as perc from fund_max_asset;
-- customer pool with money available

with customer_set as (
select customer_id, fund_id from customer_segment cs 
join fund_stats fs on cs.segment_id = fs.segment_id)
SELECT 
    fund_id,
    ao.asset_class_id, 
    cs.customer_id,
    sum(total * ao.allocation_perc / 100) AS available_amount
FROM customer_assets ca 
INNER JOIN customer_set cs on 
    cs.customer_id = ca.customer_id
INNER JOIN asset_objective_class_allocation ao 
    ON ao.asset_objective_id = ca.asset_objective_id
group by fund_id, asset_class_id, cs.customer_id
order by fund_id, cs.customer_id, asset_class_id;

delete from funds;

insert into funds (fund_name, fund_description, MINIMUM_INVESTMENT_REQUIRED, MAXIMUM_INVESTMENT_ALLOWED,FUND_ID)
values ('Name TBD', 'Description TBD', 10000, 7078653.152, 7);
insert into funds (fund_name, fund_description, MINIMUM_INVESTMENT_REQUIRED, MAXIMUM_INVESTMENT_ALLOWED,FUND_ID)
values ('Name TBD', 'Description TBD', 10000, 15026176.69, 9);
insert into funds (fund_name, fund_description, MINIMUM_INVESTMENT_REQUIRED, MAXIMUM_INVESTMENT_ALLOWED,FUND_ID)
values ('Name TBD', 'Description TBD', 10000, 11650923.65, 10);
insert into funds (fund_name, fund_description, MINIMUM_INVESTMENT_REQUIRED, MAXIMUM_INVESTMENT_ALLOWED,FUND_ID)
values ('Name TBD', 'Description TBD', 10000, 21228431.55, 11);
insert into funds (fund_name, fund_description, MINIMUM_INVESTMENT_REQUIRED, MAXIMUM_INVESTMENT_ALLOWED,FUND_ID)
values ('Name TBD', 'Description TBD', 10000, 10997206.26, 12);
insert into funds (fund_name, fund_description, MINIMUM_INVESTMENT_REQUIRED, MAXIMUM_INVESTMENT_ALLOWED,FUND_ID)
values ('Name TBD', 'Description TBD', 10000, 18117414.68, 13);
insert into funds (fund_name, fund_description, MINIMUM_INVESTMENT_REQUIRED, MAXIMUM_INVESTMENT_ALLOWED,FUND_ID)
values ('Name TBD', 'Description TBD', 10000, 114945609.8, 14);
insert into funds (fund_name, fund_description, MINIMUM_INVESTMENT_REQUIRED, MAXIMUM_INVESTMENT_ALLOWED,FUND_ID)
values ('Name TBD', 'Description TBD', 10000, 44248705.57, 15);

select * from funds;
select * from fund_Stats;

select * from fund_assets;
select * from v_asset_pool_per_fund where fund_id = 9;


alter table funds add column max_asset_pool number(38,0); 