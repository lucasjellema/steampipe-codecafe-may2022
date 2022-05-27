select
  inst.display_name,
  inst.id,
  inst.shape,
  inst.region,
  inst.lifecycle_state,
  inst.time_created,
  comp.name as compartment_name
from
  oci_core_instance inst
  inner join
    oci_identity_compartment comp
    on (inst.compartment_id = comp.id)
where comp.name = 'go-on-oci'
order by
  comp.name,
  inst.region,
  inst.shape