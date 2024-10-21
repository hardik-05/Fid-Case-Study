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


select * from v_asset_pool_per_fund;

-- fund_id, total_asset_available
WITH fund_asset_class_allocation AS (
    SELECT 
        fa.fund_id, 
        fa.asset_class_id, 
        ppf.available_amount, 
        fa.percent_of_fund, 
        ppf.available_amount * fa.percent_of_fund AS fund_per_class 
    FROM v_asset_pool_per_fund ppf
    INNER JOIN fund_assets fa 
        ON ppf.fund_id = fa.fund_id 
        AND ppf.asset_class_id = fa.asset_class_id
)
SELECT 
    fund_id, 
    SUM(fund_per_class) AS total_asset_available 
FROM fund_asset_class_allocation 
GROUP BY fund_id;


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

select * from fund_assets;

select * from customer_assets where customer_id = 842 ;
