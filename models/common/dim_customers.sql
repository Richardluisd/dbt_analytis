
select
        c_custkey as customer_id,
        c_name as full_anme 
from {{ ref("stg_TPH__CUSTOMER") }}