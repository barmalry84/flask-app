variable "base_name" {
  description = "This is used to the base name of resource"
}

variable "env" {
  description = "This is used to the env where we run resource"
}

variable "tags" {
  description = "A map of custom tags to apply to the resources. The key is the tag name and the value is the tag value."
  type        = map(string)
  default     = {}
}

variable "task_cpu" {
  description = "Container CPU"
}

variable "task_mem" {
  description = "Container memory"
}

variable "docker_image" {
  description = "Docker image that will be used in creating the container"
  type        = string
}

variable "docker_image_version" {
  description = "Docker image version that will be used in creating the container"
  type        = string
}

variable "task_count" {
  description = "Number of tasks"
}

variable "region" {
  description = "Region to run"
}