alter table asset_objectives add column target_returns integer;
update asset_objectives set target_returns = 5 where ASSET_OBJECTIVE_NAME = 'General Savings';
update asset_objectives set target_returns = 7 where ASSET_OBJECTIVE_NAME = 'Home Ownership';
update asset_objectives set target_returns = 8 where ASSET_OBJECTIVE_NAME = 'Family Planning';
update asset_objectives set target_returns = 9 where ASSET_OBJECTIVE_NAME = 'Retirement';
update asset_objectives set target_returns = 11 where ASSET_OBJECTIVE_NAME = 'Unknown';

alter table asset_classes add column avg_returns float;
update asset_classes set avg_returns = 4.5 where ASSET_CLASS = 'Bonds';
update asset_classes set avg_returns = 10.5 where ASSET_CLASS = 'Large Cap';
update asset_classes set avg_returns = 9.5 where ASSET_CLASS = 'US Mid Cap';
update asset_classes set avg_returns = 11 where ASSET_CLASS = 'US Small Cap';
update asset_classes set avg_returns = 7.5 where ASSET_CLASS = 'Foreign Ex';
update asset_classes set avg_returns = 10 where ASSET_CLASS = 'Emerging';
update asset_classes set avg_returns = 2.5 where ASSET_CLASS = 'Commodities';
update asset_classes set avg_returns = 9.5 where ASSET_CLASS = 'Market ETF';

alter table asset_classes add column benchmark varchar;
update asset_classes set benchmark = 'US Treasury Bonds' where ASSET_CLASS = 'Bonds';
update asset_classes set benchmark = 'S&P 500 Index' where ASSET_CLASS = 'Large Cap';
update asset_classes set benchmark = 'S&P MidCap 400 Index' where ASSET_CLASS = 'US Mid Cap';
update asset_classes set benchmark = 'Russell 2000 Index' where ASSET_CLASS = 'US Small Cap';
update asset_classes set benchmark = 'MSCI EAFE Index' where ASSET_CLASS = 'Foreign Ex';
update asset_classes set benchmark = 'MSCI Emerging Markets Index' where ASSET_CLASS = 'Emerging';
update asset_classes set benchmark = 'Bloomberg Commodity Index' where ASSET_CLASS = 'Commodities';
update asset_classes set benchmark = 'Vanguard Total Stock Market ETF' where ASSET_CLASS = 'Market ETF';

create or replace view v_asset_objective_class_allocation_matrix as (
WITH allocation_data AS (
    SELECT 
        aob.ASSET_OBJECTIVE_NAME, 
        ac.ASSET_CLASS, 
        ao.allocation_perc
    FROM ASSET_OBJECTIVE_CLASS_ALLOCATION ao
    JOIN asset_classes ac
    ON ao.asset_class_id = ac.asset_class_id
    JOIN ASSET_OBJECTIVES aob 
    on aob.ASSET_OBJECTIVE_ID = ao.asset_objective_id
)
SELECT * 
FROM allocation_data
PIVOT (
    MAX(allocation_perc) FOR ASSET_CLASS IN ('Bonds', 'Large Cap', 'US Mid Cap', 'US Small Cap', 
                                                  'Foreign Ex', 'Emerging', 'Commodities', 'Market ETF')
)
);



