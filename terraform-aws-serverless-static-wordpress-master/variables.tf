locals {
  graviton_fargate_regions_unsupported = [
    "af-south-1",
    "me-south-1"
  ]
}

variable "main_vpc_id" {
  type        = string
  description = "The VPC ID into which to launch resources."
  default     = "vpc-0f86c4c5af246018d"
  validation {
    condition     = length(var.main_vpc_id) > 4 && substr(var.main_vpc_id, 0, 4) == "vpc-"
    error_message = "The main_vpc_id value must be a valid VPC id, starting with \"vpc-\"."
  }
}

variable "subnet_ids" {
  type        = list(any)
  description = "A list of subnet IDs within the specified VPC where resources will be launched."
  default     = ["subnet-0ba1f8f04b1bc10bd","subnet-0a745a42813067808","subnet-0b7919ec5903ac312","subnet-08a65f2f456b48585","subnet-06209ab112627bf20","subnet-0b7ee8a5cb5731b4a"]
}


variable "aws_account_id" {
  type        = string
  description = "The AWS account ID into which resources will be launched."
  default = "059449770494"
}

/*variable "site_domain" {
  type        = string
  description = "The site domain name to configure (without any subdomains such as 'www')"
}*/

variable "site_name" {
  type        = string
  description = "The unique name for this instance of the module. Required to deploy multiple wordpress instances to the same AWS account (if desired)."
  validation {
    # regex(...) fails if it cannot find a match
    condition     = can(regex("^[0-9A-Za-z]+$", var.site_name))
    error_message = "For site_name value only a-z, A-Z and 0-9 are allowed."
  }
}

variable "site_prefix" {
  type        = string
  description = "The subdomain prefix of the website domain. E.g. www"
  default     = "www"
}

variable "s3_region" {
  type        = string
  description = "The regional endpoint to use for the creation of the S3 bucket for published static wordpress site."
}

variable "slack_webhook" {
  type        = string
  description = "The Slack webhook URL where ECS Cluster EventBridge notifications will be sent."
  default     = ""
  sensitive   = true
}

variable "launch" {
  type        = number
  default     = "0"
  description = "The number of tasks to launch of the Wordpress container. Used as a toggle to start/stop your Wordpress management session."
  validation {
    condition     = var.launch >= 0 && var.launch <= 1
    error_message = "The number of tasks to launch should be either 1 or 0 only."
  }
}

variable "ecs_cpu" {
  type        = number
  description = "The CPU limit password to the Wordpress container definition."
  default     = 256
}

variable "ecs_memory" {
  type        = number
  default     = 512
  description = "The memory limit password to the Wordpress container definition."
}

variable "snapshot_identifier" {
  description = "To create the RDS cluster from a previous snapshot in the same region, specify it by name."
  type        = string
  default     = null
}

# Backup functionality awaits: https://github.com/hashicorp/terraform-provider-aws/pull/18006
# variable "efs_backups" {
#   description = "A flag to set whether EFS default backups should be enabled (not yet implemented)."
#   type    = bool
#   default = true
# }

variable "cloudfront_aliases" {
  type        = list(any)
  description = "The domain and sub-domain aliases to use for the cloudfront distribution."
  default     = []
}

variable "cloudfront_class" {
  type        = string
  description = "The [price class](https://aws.amazon.com/cloudfront/pricing/) for the distribution. One of: PriceClass_All, PriceClass_200, PriceClass_100"
  default     = "PriceClass_All"
}

variable "cloudfront_function_301_redirects" {
  type = map(any)
  default = {
    "^(.*)index\\.php$" : "$1"
  }
  description = "A list of key value pairs of Regex match and destination for 301 redirects at CloudFront."
}

/*variable "hosted_zone_id" {
  type        = string
  description = "The Route53 HostedZone ID to use to create records in."
}

variable "waf_enabled" {
  type        = bool
  description = "Flag to enable default WAF configuration in front of CloudFront."
}*/

variable "wordpress_subdomain" {
  type        = string
  description = "The subdomain used for the Wordpress container."
  default     = "wordpress"
}

variable "wordpress_admin_user" {
  type        = string
  description = "The username of the default wordpress admin user."
  default     = "admin"
}

variable "wordpress_admin_password" {
  type        = string
  description = "The password of the default wordpress admin user."
  #tfsec:ignore:GEN001
  default   = "yobitel"
  sensitive = true
}

variable "wordpress_admin_email" {
  type        = string
  description = "The email address of the default wordpress admin user."
  default     = "admin@example.com"
}

variable "wordpress_memory_limit" {
  type        = string
  description = "The memory to allow the Wordpress process to use (in M)"
  default     = "256M"
}

variable "wp2static_version" {
  type        = string
  description = "Version of WP2Static to use from https://github.com/WP2Static/wp2static/releases"
  default     = "7.1.7"
}

variable "wp2static_s3_addon_version" {
  type        = string
  description = "Version of the WP2Static S3 Add-on to use from https://github.com/leonstafford/wp2static-addon-s3/releases/"
  default     = "1.0"
}

/*variable "waf_acl_rules" {
  type        = list(any)
  description = "List of WAF rules to apply. Can be customized to apply others created outside of module."
  default = [
    {
      name                       = "AWS-AWSManagedRulesAmazonIpReputationList"
      priority                   = 0
      managed_rule_group_name    = "AWSManagedRulesAmazonIpReputationList"
      vendor_name                = "AWS"
      cloudwatch_metrics_enabled = true
      metric_name                = "AWS-AWSManagedRulesAmazonIpReputationList"
      sampled_requests_enabled   = true
    },
    {
      name                       = "AWS-AWSManagedRulesKnownBadInputsRuleSet"
      priority                   = 1
      managed_rule_group_name    = "AWSManagedRulesKnownBadInputsRuleSet"
      vendor_name                = "AWS"
      cloudwatch_metrics_enabled = true
      metric_name                = "AWS-AWSManagedRulesKnownBadInputsRuleSet"
      sampled_requests_enabled   = true
    },
    {
      name                       = "AWS-AWSManagedRulesBotControlRuleSet"
      priority                   = 2
      managed_rule_group_name    = "AWSManagedRulesBotControlRuleSet"
      vendor_name                = "AWS"
      cloudwatch_metrics_enabled = true
      metric_name                = "AWS-AWSManagedRulesBotControlRuleSet"
      sampled_requests_enabled   = true
    }
  ]
}*/

variable "graviton_codebuild_enabled" {
  type        = bool
  default     = false
  description = "Flag that controls whether CodeBuild should use Graviton-based build agents in [supported regions](https://docs.aws.amazon.com/codebuild/latest/userguide/build-env-ref-compute-types.html)."
}

variable "graviton_fargate_enabled" {
  type        = bool
  default     = false
  description = "Flag that controls whether ECS Fargate should use Graviton-based containers in [supported regions]https://docs.aws.amazon.com/AmazonECS/latest/developerguide/AWS_Fargate-Regions.html)."
}
