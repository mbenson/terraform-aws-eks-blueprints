resource "helm_release" "addon" {
  count                      = var.manage_via_gitops ? 0 : 1
  name                       = var.helm_config.name
  repository                 = var.helm_config.repository
  chart                      = var.helm_config.chart
  version                    = var.helm_config.version
  timeout                    = var.helm_config.timeout
  values                     = var.helm_config.values
  create_namespace           = var.irsa_config == null && var.helm_config.create_namespace
  namespace                  = var.helm_config.namespace
  lint                       = var.helm_config.lint
  description                = var.helm_config.description
  repository_key_file        = var.helm_config.repository_key_file
  repository_cert_file       = var.helm_config.repository_cert_file
  repository_username        = var.helm_config.repository_username
  repository_password        = var.helm_config.repository_password
  verify                     = var.helm_config.verify
  keyring                    = var.helm_config.keyring
  disable_webhooks           = var.helm_config.disable_webhooks
  reuse_values               = var.helm_config.reuse_values
  reset_values               = var.helm_config.reset_values
  force_update               = var.helm_config.force_update
  recreate_pods              = var.helm_config.recreate_pods
  cleanup_on_fail            = var.helm_config.cleanup_on_fail
  max_history                = var.helm_config.max_history
  atomic                     = var.helm_config.atomic
  skip_crds                  = var.helm_config.skip_crds
  render_subchart_notes      = var.helm_config.render_subchart_notes
  disable_openapi_validation = var.helm_config.disable_openapi_validation
  wait                       = var.helm_config.wait
  wait_for_jobs              = var.helm_config.wait_for_jobs
  dependency_update          = var.helm_config.dependency_update
  replace                    = var.helm_config.replace

  postrender {
    binary_path = var.helm_config.postrender
  }

  dynamic "set" {
    iterator = each_item
    for_each = distinct(concat(var.set_values, var.helm_config.set))

    content {
      name  = each_item.value.name
      value = each_item.value.value
      type  = each_item.value.type
    }
  }

  dynamic "set_sensitive" {
    iterator = each_item
    for_each = distinct(concat(var.helm_config.set_sensitive, var.set_sensitive_values))

    content {
      name  = each_item.value.name
      value = each_item.value.value
      type  = each_item.value.type
    }
  }
  depends_on = [module.irsa]
}

module "irsa" {
  count                             = var.irsa_config != null ? 1 : 0
  source                            = "../../irsa"
  create_kubernetes_namespace       = var.irsa_config.create_kubernetes_namespace
  create_kubernetes_service_account = var.irsa_config.create_kubernetes_service_account
  kubernetes_namespace              = var.irsa_config.kubernetes_namespace
  kubernetes_service_account        = var.irsa_config.kubernetes_service_account
  kubernetes_svc_image_pull_secrets = var.irsa_config.kubernetes_svc_image_pull_secrets
  irsa_iam_policies                 = var.irsa_config.irsa_iam_policies
  irsa_iam_role_name                = var.irsa_iam_role_name
  irsa_iam_role_path                = var.addon_context.irsa_iam_role_path
  irsa_iam_permissions_boundary     = var.addon_context.irsa_iam_permissions_boundary
  eks_cluster_id                    = var.addon_context.eks_cluster_id
  eks_oidc_provider_arn             = var.addon_context.eks_oidc_provider_arn
}
