variable "launch_template_config" {
  description = "Launch template configuration"
  type = map(object({
    ami                    = string
    launch_template_os     = optional(string, "amazonlinux2eks")
    launch_template_prefix = string
    instance_type          = optional(string)
    capacity_type          = optional(string, "")
    iam_instance_profile   = optional(string)
    vpc_security_group_ids = optional(list(string), []) # conflicts with network_interfaces

    network_interfaces = optional(list(object({
      public_ip       = optional(bool, false)
      security_groups = optional(list(string), [])
    })), [{}])

    block_device_mappings = list(object({
      device_name           = optional(string, "/dev/xvda")
      # The volume type. Can be standard, gp2, gp3, io1, io2, sc1 or st1 (Default: gp3).
      volume_type           = optional(string, "gp3")
      volume_size           = optional(number, 200)
      delete_on_termination = optional(bool, true)
      encrypted             = optional(bool, true)
      kms_key_id            = optional(string)
      iops                  = optional(number, 3000)
      throughput            = optional(number, 125)
    }))

    format_mount_nvme_disk = optional(bool, false)
    pre_userdata           = optional(string, "")
    bootstrap_extra_args   = optional(string, "")
    post_userdata          = optional(string, "")
    kubelet_extra_args     = optional(string, "")

    enable_metadata_options     = optional(bool, true)
    http_endpoint               = optional(string, "enabled")
    http_tokens                 = optional(string, "required")
    http_put_response_hop_limit = optional(number, 2)
    http_protocol_ipv6          = optional(string, "disabled")
    instance_metadata_tags      = optional(string, "disabled")

    service_ipv6_cidr = optional(string, "")
    service_ipv4_cidr = optional(string, "")

    monitoring = optional(bool, true)
  }))
}

variable "eks_cluster_id" {
  description = "EKS Cluster ID"
  type        = string
}

variable "tags" {
  description = "Additional tags (e.g. `map('BusinessUnit`,`XYZ`)"
  type        = map(string)
  default     = {}
}
