-- adding fund id to funds_composition table
alter table
    FUNDS_COMPOSITION
add
    column fund_id INTEGER;
UPDATE
    FUNDS_COMPOSITION
set
    fund_id = rn
from
    (
        select
            fund_name,
            row_number() over (
                order by
                    fund_name
            ) as rn
        from
            FUNDS_COMPOSITION
    ) as temp
where
    FUNDS_COMPOSITION.fund_name = temp.fund_name;
ALTER table
    funds_composition
add
    primary key(fund_id);
-- removing dummy values
delete from
    fund_assets;
-- changing type to float
alter table
    fund_assets drop column percent_of_fund;
alter table
    fund_assets
add
    column percent_of_fund float;
-- adding the asset composition to the fund_assets table
insert into
    fund_assets (asset_class_id, fund_id, percent_of_fund)
select
    1 as asset_class_id,
    fund_id,
    asset_1 as percent_of_fund
from
    funds_composition
union all
select
    2 as asset_class_id,
    fund_id,
    asset_2 as percent_of_fund
from
    funds_composition
union all
select
    3 as asset_class_id,
    fund_id,
    asset_3 as percent_of_fund
from
    funds_composition
union all
select
    4 as asset_class_id,
    fund_id,
    asset_4 as percent_of_fund
from
    funds_composition
union all
select
    5 as asset_class_id,
    fund_id,
    asset_5 as percent_of_fund
from
    funds_composition
union all
select
    6 as asset_class_id,
    fund_id,
    asset_6 as percent_of_fund
from
    funds_composition
union all
select
    7 as asset_class_id,
    fund_id,
    asset_7 as percent_of_fund
from
    funds_composition
union all
select
    8 as asset_class_id,
    fund_id,
    asset_8 as percent_of_fund
from
    funds_composition;
-- creating cleaner table
    create
    or replace table fund_stats (
        fund_id INTEGER PRIMARY KEY,
        WEIGHTED_RISK FLOAT,
        WEIGHTED_FEES FLOAT,
        WEIGHTED_RETURN FLOAT
    );
-- loading data from 3 tables to the cleaner table
insert into
    fund_stats with risk_fund as (
        with df as (
            select
                fa.fund_id as fund_id,
                risk_profile_id,
                percent_of_fund,
                ac.asset_class_id
            from
                asset_classes ac
                inner join fund_assets fa on fa.asset_class_id = ac.asset_class_id
        )
        select
            fund_id,
            sum(risk_profile_id * percent_of_fund) as weighted_risk,
        from
            df
        group by
            fund_id
    )
select
    fc.fund_id,
    rf.weighted_risk,
    weighted_fees,
    weighted_return
from
    funds_composition fc
    inner join risk_fund rf on fc.fund_id = rf.fund_id;
-- creating segment table
    create
    or replace table segments (
        segment_id INTEGER,
        description VARCHAR,
        avg_segment_risk FLOAT
    );
insert into
    segments (segment_id, avg_segment_risk)
select
    1 as segment_id,
    avg_group_risk as avg_segment_risk
from
    segment_1
limit
    1;
insert into
    segments (segment_id, avg_segment_risk)
select
    2 as segment_id,
    avg_group_risk as avg_segment_risk
from
    segment_2
limit
    1;
insert into
    segments (segment_id, avg_segment_risk)
select
    3 as segment_id,
    avg_group_risk as avg_segment_risk
from
    segment_3
limit
    1;
insert into
    segments (segment_id, avg_segment_risk)
select
    4 as segment_id,
    avg_group_risk as avg_segment_risk
from
    segment_4
limit
    1;
insert into
    segments (segment_id, avg_segment_risk)
select
    5 as segment_id,
    avg_group_risk as avg_segment_risk
from
    segment_5
limit
    1;
-- customer segment table
delete from
    customer_segment;
insert into
    customer_segment (customer_id, segment_id) with segments as (
        select
            1 as segment_id,
            avg_risk,
            cst as customer_id,
            avg_group_risk
        from
            segment_1
        union all
        select
            2 as segment_id,
            avg_risk,
            cst as customer_id,
            avg_group_risk
        from
            segment_2
        union all
        select
            3 as segment_id,
            avg_risk,
            cst as customer_id,
            avg_group_risk
        from
            segment_3
        union all
        select
            4 as segment_id,
            avg_risk,
            cst as customer_id,
            avg_group_risk
        from
            segment_4
        union all
        select
            5 as segment_id,
            avg_risk,
            cst as customer_id,
            avg_group_risk
        from
            segment_5
    )
select
    customer_id,
    segment_id
from
    segments;
-- segment matching using the fund_stats table
alter table
    fund_stats
add
    column segment_id INTEGER;
-- creating a view to store the funds that match.
    create
    or replace view matching_fund_segments as (
        select
            fund_id,
            avg_segment_risk,
            s.segment_id,
            ROW_NUMBER() OVER (
                PARTITION BY fund_id
                ORDER BY
                    ABS(avg_segment_risk - weighted_risk) desc
            ) AS risk_rank
        from
            segments s
            join fund_stats
        where
            avg_segment_risk > 0.95 * weighted_risk
            and avg_segment_risk < 1.05 * weighted_risk
    );
-- using the view to store the target segments in fund stats table
update
    fund_stats fs
set
    fs.segment_id = ms.segment_id
from
    matching_fund_segments ms
where
    ms.fund_id = fs.fund_id
    and ms.risk_rank = 1;



-- matching customers to funds


SELECT 
    c.customer_id,
    f.fund_id,
FROM 
    customers c
JOIN 
    customer_assets ca ON c.customer_id = ca.customer_id
JOIN 
    fund_assets fca ON ca.asset_class_id = fca.asset_class_id
JOIN 
    fund_stats f ON fca.fund_id = f.fund_id
GROUP BY 
    c.customer_id, f.fund_id;
