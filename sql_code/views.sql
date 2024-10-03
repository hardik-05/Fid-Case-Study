--VIEWS



-- V_CUSTOMERS_AGE_DISTRIBUTION
create or replace view CASESTUDY_WORKING.PUBLIC.V_CUSTOMERS_AGE_DISTRIBUTION (AGE_RANGE, NO_OF_CUSTOMERS) as select get_age_range(age) as age_range ,count(customer_id) as no_of_customers from eligible_customers group by get_age_range(age);

--Age and Gender Distribution:
create  or replace view v_age_gender_dist as select count(customer_id) as NO_OF_CUSTOMERS,coalesce(gender,'OTHERS') as gender,get_age_range(age) as AGE_RANGE from v_eligible_customers group by gender,get_age_range(age);

--V_REGIONAL_DISTRIBUTION
create or replace view CASESTUDY_WORKING.PUBLIC.V_REGIONAL_DISTRIBUTION(STATE, CITY, NO_OF_CUSTOMERS) as select state,city ,count(customer_id) as no_of_customers from eligible_customers group by city,state order by state;

--V_MARITAL_STATUS
create or replace view CASESTUDY_WORKING.PUBLIC.V_MARITAL_STATUS( MARITAL_STATUS, NO_OF_CUSTOMERS) as select Coalesce( marital_status,'Unknown') as marital_status,count(customer_id) as no_of_customers from eligible_customers group by marital_status;
 
--V_ELIGIBLE_CUSTOMERS
create or replace view CASESTUDY_WORKING.PUBLIC.ELIGIBLE_CUSTOMERS(CUSTOMER_ID, CONTACT_LAST_NAME, CONTACT_FIRST_NAME, STREET, CITY, STATE ,ZIP, COUNTRY, AGE,MARITAL_STATUS,GENDER,NUMBER_OF_DEPENDENTS, CID, "COUNT(CA.QUESTION_ID)") as (
with valid_customer_ids as (select customer_id as cid,count(ca.question_id) from customer_answers ca join answers a on ca.answer_id=a.answer_id and ca.question_id =a.question_id group by customer_id having count(ca.question_id)>=6)
select * from customers c inner join valid_customer_ids vc on c.customer_id=vc.cid);

--V_ELIGIBLE_CUSTOMERS_DEPENDENTS
create or replace view CASESTUDY_WORKING.PUBLIC.V_ELIGIBLE_CUSTOMERS_DEPENDENTS( CUSTOMER_ID, NUMBER_OF_DEPENDENTS, TOTAL) as select ec.customer_id, ec.number_of_dependents, cs.total from v_eligible_customers ec join customer_assets cs on cs.customer_id=ec.customer_id ;

--V_AGE_GENDER_SEGMENTS

create or replace view CASESTUDY_WORKING.PUBLIC.V_AGE_GENDER_SEGMENTS( GENDER, AGE_RANGE, MIN_ASSETS, MAX_ASSETS, SEGMENT_ID, RANGE_OF_ASSETS, AVG_ASSETS) as select coalesce(gender,'Others') as gender, get_age_range(age) as age_range, min(ca.total) as min_assets, max(ca.total) as max_assets, 
get_segment(gender,get_age_range(age)) as segment_id,
concat(round(min(ca.total),2),' - ',round(max(ca.total),2)) as range_of_assets,
avg(ca.total) as avg_assets, from v_eligible_customers c join customer_assets ca on c.customer_id=ca.customer_id group by gender, get_age_range(age) , 
get_segment(gender,get_age_range(age))
having gender !='Others'
order by segment_id;

--V_GENDER_SEGMENTS
create or replace view v_gender_segments as select segment_id,count(CASE WHEN gender='Male' THEN 1 END) as male_count, count(CASE WHEN gender='Female' THEN 1 END) as female_count from customer_segment cs join v_eligible_customers ec on ec.customer_id=cs.customer_id group by segment_id;

----v_marital_status_segments 
create or replace view v_marital_status_segments as select segment_id,count(CASE WHEN marital_status='Married' THEN 1 END) as married_count, count(CASE WHEN marital_status='Single' THEN 1 END) as single_count, count(CASE WHEN marital_status='Divorced' THEN 1 END) as divorced_count from customer_segment cs join v_eligible_customers ec on ec.customer_id=cs.customer_id group by segment_id;

V_AGE_BY_RISK
create or replace view CASESTUDY_WORKING.PUBLIC.V_AGE_BY_RISK(AVG_AGE,MAX_AGE,LEAST_AGE,PCT_CST,HEAD_COUNT,RISK_PROFILE_ID) as (
select  avg(age) as avg_age,max(age) as max_age, min(age) as least_age,(count(c.customer_id) / (select count(*) from v_eligible_customers)) * 100 as pct_cst, count(c.customer_id) as head_count , risk_profile_id as risk_profile_id from v_eligible_customers c join v_customer_risk_profile cr on c.customer_id = cr.customer_id group by risk_profile_id order by count(c.customer_id) desc);

--V_INVST_BY_RISK
create or replace view CASESTUDY_WORKING.PUBLIC.V_INVST_BY_RISK(AVG_INVST, MAX_INVST, MIN_INVST, PCT_CST, HEAD_COUNT, RISK_PROFILE_ID) as (select sum(total) as avg_invst, max(total) as max_invst, min(total) as min_invst,(count(c.customer_id) / (select count(*) from v_eligible_customers)) * 20 as pct_cst, count(distinct c.customer_id) as head_count , risk_profile_id as risk_profile_id from v_eligible_customers c join v_customer_risk_profile cr on c.customer_id = cr.customer_id join customer_assets ca on cr.customer_id = ca.customer_id  group by risk_profile_id order by count(c.customer_id) desc)
