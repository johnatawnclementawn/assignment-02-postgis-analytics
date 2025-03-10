-- 3. Using the Philadelphia Water Department Stormwater Billing Parcels dataset, pair each parcel with its closest bus stop. 
-- The final result should give the parcel address, bus stop name, and distance apart in meters. 
-- Order by distance (largest on top).

--   **Structure:**
--   ```sql
--   (
--       address text,  -- The address of the parcel
--       stop_name text,  -- The name of the bus stop
--       distance_m double precision  -- The distance apart in meters
--   )
--   ```
DROP INDEX IF EXISTS septa_bus_stops_the_geom_idx;
create index septa_bus_stops_the_geom_idx
    on septa_bus_stops
    using GiST(st_transform(the_geom, 32129));

DROP INDEX IF EXISTS pwd_parcels_the_geom_idx;
CREATE index pwd_parcels_the_geom_idx
	on pwd_parcels
	using GiST(st_transform(the_geom, 32129));

with parcels as(
	select the_geom, address
	from pwd_parcels
), bus_stops as (
	select stop_name, the_geom
	from septa_bus_stops
)

select address, stop_name, distance_m
from parcels as p
	cross join lateral(
		select stop_name, st_transform(p.the_geom,32129) <-> st_transform(s.the_geom,32129) as distance_m
		from bus_stops s
		order by distance_m
		limit 1
	) closestBusStation
order by distance_m desc;
