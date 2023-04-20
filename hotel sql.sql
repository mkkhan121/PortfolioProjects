With hotels as(
Select * from dbo.['2018$']
Union
Select * from dbo.['2019$']
Union
Select * from dbo.['2020$'])

Select arrival_date_year,hotel,
round(sum((stays_in_week_nights+stays_in_weekend_nights)*adr),2) as revenue
From hotels
Group by arrival_date_year,hotel


With hotels as(
Select * from dbo.['2018$']
Union
Select * from dbo.['2019$']
Union
Select * from dbo.['2020$'])
Select * from hotels
left join dbo.market_segment$
on hotels.market_segment = market_segment$.market_segment
left join dbo.meal_cost$
on meal_cost$.meal = hotels.meal
