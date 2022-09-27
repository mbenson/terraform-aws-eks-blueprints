variable "helm_config" {
  description = "Helm chart config. See https://registry.terraform.io/providers/hashicorp/helm/latest/docs"
  type        = object({
    name                       = string
    repository                 = optional(string)
    chart                      = string
    version                    = optional(string)
    timeout                    = optional(number, 1200)
    values                     = optional(string)
    create_namespace           = optional(bool, false)
    namespace                  = optional(string, "default")
    lint                       = optional(bool, false)
    description                = optional(string, "")
    repository_key_file        = optional(string, "")
    repository_cert_file       = optional(string, "")
    repository_username        = optional(string, "")
    repository_password        = optional(string, "")
    verify                     = optional(bool, false)
    keyring                    = optional(string, "")
    disable_webhooks           = optional(bool, false)
    reuse_values               = optional(bool, false)
    reset_values               = optional(bool, false)
    force_update               = optional(bool, false)
    recreate_pods              = optional(bool, false)
    cleanup_on_fail            = optional(bool, false)
    max_history                = optional(number, 0)
    atomic                     = optional(bool, false)
    skip_crds                  = optional(bool, false)
    render_subchart_notes      = optional(bool, true)
    disable_openapi_validation = optional(bool, false)
    wait                       = optional(bool, true)
    wait_for_jobs              = optional(bool, false)
    dependency_update          = optional(bool, false)
    replace                    = optional(bool, false)
    postrender                 = optional(string, "")
    set                        = optional(list(object({name = string, value = string, type = optional(string)})), [])
    set_sensitive              = optional(list(object({name = string, value = string, type = optional(string)})), [])
  })
}

variable "set_values" {
  description = "Forced set values"
  type        = list(object({name = string, value = string, type = optional(string)}))
  default     = []
}

variable "set_sensitive_values" {
  description = "Forced set_sensitive values"
  type        = list(object({name = string, value = string, type = optional(string)}))
  default     = []
}

variable "manage_via_gitops" {
  description = "Determines if the add-on should be managed via GitOps"
  type        = bool
  default     = false
}

variable "irsa_iam_role_name" {
  type        = string
  description = "IAM role name for IRSA"
  default     = ""
}

variable "irsa_config" {
  description = "Input configuration for IRSA module"
  type = object({
    kubernetes_namespace              = string
    create_kubernetes_namespace       = optional(bool, true)
    kubernetes_service_account        = string
    create_kubernetes_service_account = optional(bool, true)
    kubernetes_svc_image_pull_secrets = optional(list(string))
    irsa_iam_policies                 = optional(list(string))
  })
  default = null
}

variable "addon_context" {
  description = "Input configuration for the addon"
  type = object({
    aws_caller_identity_account_id = string
    aws_caller_identity_arn        = string
    aws_eks_cluster_endpoint       = string
    aws_partition_id               = string
    aws_region_name                = string
    eks_cluster_id                 = string
    eks_oidc_issuer_url            = string
    eks_oidc_provider_arn          = string
    tags                           = map(string)
    irsa_iam_role_path             = optional(string)
    irsa_iam_permissions_boundary  = optional(string)
  })
}
