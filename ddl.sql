create schema if not exists dwh;

drop table if exists dwh.fact_sales;
drop table if exists dwh.dim_supplier;
drop table if exists dwh.dim_product;
drop table if exists dwh.dim_store;
drop table if exists dwh.dim_seller;
drop table if exists dwh.dim_customer;
drop table if exists dwh.dim_date;

create table dwh.dim_customer (
    customer_key bigserial primary key,
    customer_bk text,
    source_customer_id integer,
    first_name text,
    last_name text,
    email text,
    country text,
    pet_type text
);

create table dwh.dim_seller (
    seller_key bigserial primary key,
    seller_bk text,
    source_seller_id integer,
    first_name text,
    last_name text,
    email text,
    country text
);

create table dwh.dim_store (
    store_key bigserial primary key,
    store_bk text,
    store_name text,
    city text,
    country text
);

create table dwh.dim_product (
    product_key bigserial primary key,
    product_bk text,
    source_product_id integer,
    product_name text,
    product_category text,
    brand text,
    unit_price numeric(12,2)
);

create table dwh.dim_supplier (
    supplier_key bigserial primary key,
    supplier_bk text,
    supplier_name text,
    email text,
    country text
);

create table dwh.fact_sales (
    sale_key bigserial primary key,
    source_row_id bigint,
    sale_date date,
    customer_key bigint references dwh.dim_customer(customer_key),
    seller_key bigint references dwh.dim_seller(seller_key),
    store_key bigint references dwh.dim_store(store_key),
    product_key bigint references dwh.dim_product(product_key),
    supplier_key bigint references dwh.dim_supplier(supplier_key),
    sale_quantity integer,
    sale_total_price numeric(12,2)
);
