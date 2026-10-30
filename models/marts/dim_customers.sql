with customers as (
    select * from {{ ref('stg_customers') }}
),
 
customer_orders as (
    select
        customer_id,
        count(order_id) as number_of_orders,
        min(order_date) as first_order_date,
        max(order_date) as most_recent_order_date
    from {{ ref('stg_orders') }}
    group by customer_id
),
 
customer_payments as (
    select
        orders.customer_id,
        sum({{ cents_to_dollars('payments.amount_cents') }}) as lifetime_value
    from {{ ref('stg_orders') }} as orders
    left join {{ ref('stg_payments') }} as payments
        on orders.order_id = payments.order_id
    group by orders.customer_id
)
 
select
    customers.customer_id,
    customers.first_name,
    customers.last_name,
    customers.email,
    coalesce(customer_orders.number_of_orders, 0) as number_of_orders,
    customer_orders.first_order_date,
    customer_orders.most_recent_order_date,
    coalesce(customer_payments.lifetime_value, 0) as lifetime_value
from customers
left join customer_orders on customers.customer_id = customer_orders.customer_id
left join customer_payments on customers.customer_id = customer_payments.customer_id