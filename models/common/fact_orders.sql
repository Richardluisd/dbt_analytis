{{
    config(
        materialized='incremental',
        unique_key='O_ORDERDATE',
        on_schema_change='fail'
    )
}}

/*
    Modelo incremental que carga orders de los últimos X años
    Configurable mediante variable 'anios_historico' (default: 2 años)
*/

with orders_inc as (
    select
        O_ORDERKEY,
        O_ORDERDATE,
        O_CUSTKEY,
        O_TOTALPRICE
    from {{ ref("stg_TPH__ORDERS") }}
    where O_ORDERDATE >= dateadd(year, -{{ var('anios_historico', 2) }}, current_date())
    
    {% if is_incremental() %}
        -- En ejecuciones incrementales, solo traer registros nuevos
        and O_ORDERDATE > (select max(O_ORDERDATE) from {{ this }})
    {% endif %}
),

fact_orders as (
    select
        O_ORDERKEY,
        O_ORDERDATE,
        O_CUSTKEY,
        O_TOTALPRICE
    from orders_inc
)

select * from fact_orders