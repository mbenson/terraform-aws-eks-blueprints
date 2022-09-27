resource "aws_launch_template" "this" {
  for_each = var.launch_template_config

  name        = format("%s-%s", each.value.launch_template_prefix, var.eks_cluster_id)
  description = "Launch Template for Amazon EKS Worker Nodes"

  image_id               = each.value.ami
  update_default_version = true

  instance_type = try(coalesce(each.value.instance_type), null)

  user_data = base64encode(templatefile("${path.module}/templates/userdata-${each.value.launch_template_os}.tpl",
    {
      pre_userdata           = each.value.pre_userdata
      post_userdata          = each.value.post_userdata
      bootstrap_extra_args   = each.value.bootstrap_extra_args
      kubelet_extra_args     = each.value.kubelet_extra_args
      eks_cluster_id         = var.eks_cluster_id
      cluster_ca_base64      = data.aws_eks_cluster.eks.certificate_authority[0].data
      cluster_endpoint       = data.aws_eks_cluster.eks.endpoint
      service_ipv6_cidr      = each.value.service_ipv6_cidr
      service_ipv4_cidr      = each.value.service_ipv4_cidr
      format_mount_nvme_disk = each.value.format_mount_nvme_disk
  }))

  dynamic "iam_instance_profile" {
    for_each = { for p in compact(each.value.iam_instance_profile): iam_instance_profile => p }
    iterator = iam
    content {
      name = iam.value
    }
  }

  dynamic "instance_market_options" {
    for_each = trimspace(lower(each.value.capacity_type)) == "spot" ? { enabled = true } : {}

    content {
      market_type = each.value.capacity_type
    }
  }

  ebs_optimized = true

  dynamic "block_device_mappings" {
    for_each = each.value.block_device_mappings

    content {
      device_name = try(block_device_mappings.value.device_name, null)

      ebs {
        delete_on_termination = block_device_mappings.value.delete_on_termination
        encrypted             = block_device_mappings.value.encrypted
        kms_key_id            = block_device_mappings.value.kms_key_id
        volume_size           = block_device_mappings.value.volume_size
        volume_type           = block_device_mappings.value.volume_type
        iops                  = block_device_mappings.value.volume_type == "gp3" || block_device_mappings.value.volume_type == "io1" || block_device_mappings.value.volume_type == "io2" ? block_device_mappings.value.iops : null
        throughput            = block_device_mappings.value.volume_type == "gp3" ? block_device_mappings.value.throughput : null
      }
    }
  }

  vpc_security_group_ids = each.value.vpc_security_group_ids

  dynamic "network_interfaces" {
    for_each = each.value.network_interfaces
    content {
      associate_public_ip_address = network_interfaces.value.public_ip
      security_groups             = network_interfaces.value.security_groups
    }
  }

  dynamic "monitoring" {
    for_each = each.value.monitoring ? [1] : []

    content {
      enabled = true
    }
  }

  dynamic "metadata_options" {
    for_each = each.value.enable_metadata_options ? [1] : []

    content {
      http_endpoint               = each.value.http_endpoint
      http_tokens                 = each.value.http_tokens
      http_put_response_hop_limit = each.value.http_put_response_hop_limit
      http_protocol_ipv6          = each.value.http_protocol_ipv6
      instance_metadata_tags      = each.value.instance_metadata_tags
    }
  }

  lifecycle {
    create_before_destroy = true
  }

  tag_specifications {
    resource_type = "instance"
    tags          = length(var.tags) > 0 ? var.tags : { Name = "eks" }
  }

  tag_specifications {
    resource_type = "volume"
    tags          = length(var.tags) > 0 ? var.tags : { Name = "eks-volume" }
  }
}
