module "tagging" {
    source = "./tagging"
    name = var.solution_name
    stage = var.stage
    namespace = var.namespace
    CE_MIO_Code = var.CE_MIO_Code
    CE_Application_ID = var.CE_Application_ID
    CE_SLA = var.CE_SLA
    CE_Business_Entity = var.CE_Business_Entity
    CE_Instance_Scheduler = var.CE_Instance_Scheduler
}
