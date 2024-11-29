locals {
  original_tags = join(var.delimiter, compact(concat(list(var.namespace, var.stage, var.name), var.attributes)))
}

locals {
  convert_case = var.convert_case == "true" ? true : false 
}

locals {
  transformed_tags = local.convert_case == true ? lower(local.original_tags) : local.original_tags
}

locals {
  enabled = var.enabled == "true" ? true : false 

  id = local.enabled == true ? local.transformed_tags : ""

  name       = local.enabled == true ? (local.convert_case == true ? lower(format("%v", var.name)) : format("%v", var.name)) : ""
  namespace  = local.enabled == true ? (local.convert_case == true ? lower(format("%v", var.namespace)) : format("%v", var.namespace)) : ""
  stage      = local.enabled == true ? (local.convert_case == true ? lower(format("%v", var.stage)) : format("%v", var.stage)) : ""
  attributes = local.enabled == true ? (local.convert_case == true ? lower(format("%v", join(var.delimiter, compact(var.attributes)))) : format("%v", join(var.delimiter, compact(var.attributes)))): ""

# the mandatory tags are : CE_MIO_Code, CE_Business_Entity, CE_Application_ID, CE_SLA, CE_Instance_S cheduler 

CE_MIO_Code = local.enabled == true ? (local.convert_case == true ? lower(format("%v", var.CE_MIO_Code)) : format("%v", var.CE_MIO_Code)) : ""
CE_Business_Entity   = local.enabled == true ? (local.convert_case == true ? lower(format("%v", var.CE_Business_Entity)) : format("%v", var.CE_Business_Entity)) : ""
CE_Application_ID      = local.enabled == true ? (local.convert_case == true ? lower(format("%v", var.CE_Application_ID)) : format("%v", var.CE_Application_ID)) : ""
CE_Instance_Scheduler  = local.enabled == true ? (local.convert_case == true ? lower(format("%v", var.CE_Instance_Scheduler)) : format("%v", var.CE_Instance_Scheduler)) : ""  
CE_SLA = local.enabled == true ? (local.convert_case == true ? lower(format("%v", var.CE_SLA)) : format("%v", var.CE_SLA)) : "" 

# Merge input tags with our tags.
# Note: `Name` has a special meaning in AWS and we need to disamgiuate it by using the computed `id`

tags = merge( 
      map(
        "Name", local.id,
        #"Namespace", local.namespace,
        #"Stage", local.stage,
        #"Attributes", local.attributes,
        "CE_MIO_Code", local.CE_MIO_Code,
        "CE_Business_Entity", local.CE_Business_Entity,
        "CE_Application_ID", local.CE_Application_ID,
        "CE_Instance_Scheduler", local.CE_Instance_Scheduler,
        "CE_SLA", local.CE_SLA,
      ), var.tags
    )

    instanceTags =  merge( 
      map(
        "Name", local.id,
        "CE_MIO_Code", local.CE_MIO_Code,
        "CE_Business_Entity", local.CE_Business_Entity,
        "CE_Application_ID", local.CE_Application_ID,
        "CE_Instance_Scheduler", local.CE_Instance_Scheduler,
        "CE_SLA", local.CE_SLA,
      ), var.tags
    )    
}
