drop table if exists src;

create temp table src as
select
    row_number() over (order by id, sale_date, customer_email) as source_row_id,
    to_date(sale_date, 'MM/DD/YYYY') as sale_date,
    sale_customer_id::integer as sale_customer_id,
    sale_seller_id::integer as sale_seller_id,
    sale_product_id::integer as sale_product_id,
    sale_quantity::integer as sale_quantity,
    sale_total_price::numeric(12,2) as sale_total_price,
    customer_first_name,
    customer_last_name,
    customer_email,
    customer_country,
    customer_pet_type,
    seller_first_name,
    seller_last_name,
    seller_email,
    seller_country,
    store_name,
    store_city,
    store_country,
    product_name,
    product_category,
    product_brand,
    product_price::numeric(12,2) as product_price,
    supplier_name,
    supplier_email,
    supplier_country,
    md5(concat_ws('|', customer_email, customer_first_name, customer_last_name)) as customer_bk,
    md5(concat_ws('|', seller_email, seller_first_name, seller_last_name)) as seller_bk,
    md5(concat_ws('|', store_name, store_city, store_country)) as store_bk,
    md5(concat_ws('|', product_name, product_category, product_brand)) as product_bk,
    md5(concat_ws('|', supplier_name, supplier_email, supplier_country)) as supplier_bk
from mock_data;

insert into dwh.dim_date (date_key, full_date, month_num, year_num)
select distinct
    to_char(sale_date, 'YYYYMMDD')::integer,
    sale_date,
    extract(month from sale_date)::integer,
    extract(year from sale_date)::integer
from src
where sale_date is not null;

insert into dwh.dim_customer (
    customer_bk,
    source_customer_id,
    first_name,
    last_name,
    email,
    country,
    pet_type
)
select distinct on (customer_bk)
    customer_bk,
    sale_customer_id,
    customer_first_name,
    customer_last_name,
    customer_email,
    customer_country,
    customer_pet_type
from src
order by customer_bk, source_row_id;

insert into dwh.dim_seller (
    seller_bk,
    source_seller_id,
    first_name,
    last_name,
    email,
    country
)
select distinct on (seller_bk)
    seller_bk,
    sale_seller_id,
    seller_first_name,
    seller_last_name,
    seller_email,
    seller_country
from src
order by seller_bk, source_row_id;

insert into dwh.dim_store (
    store_bk,
    store_name,
    city,
    country
)
select distinct on (store_bk)
    store_bk,
    store_name,
    store_city,
    store_country
from src
order by store_bk, source_row_id;

insert into dwh.dim_product (
    product_bk,
    source_product_id,
    product_name,
    product_category,
    brand,
    unit_price
)
select distinct on (product_bk)
    product_bk,
    sale_product_id,
    product_name,
    product_category,
    product_brand,
    product_price
from src
order by product_bk, source_row_id;

insert into dwh.dim_supplier (
    supplier_bk,
    supplier_name,
    email,
    country
)
select distinct on (supplier_bk)
    supplier_bk,
    supplier_name,
    supplier_email,
    supplier_country
from src
order by supplier_bk, source_row_id;

insert into dwh.fact_sales (
    source_row_id,
    date_key,
    customer_key,
    seller_key,
    store_key,
    product_key,
    supplier_key,
    sale_quantity,
    sale_total_price
)
select
    s.source_row_id,
    to_char(s.sale_date, 'YYYYMMDD')::integer,
    c.customer_key,
    se.seller_key,
    st.store_key,
    p.product_key,
    su.supplier_key,
    s.sale_quantity,
    s.sale_total_price
from src s
join dwh.dim_customer c on c.customer_bk = s.customer_bk
join dwh.dim_seller se on se.seller_bk = s.seller_bk
join dwh.dim_store st on st.store_bk = s.store_bk
join dwh.dim_product p on p.product_bk = s.product_bk
join dwh.dim_supplier su on su.supplier_bk = s.supplier_bk
where s.sale_date is not null;
