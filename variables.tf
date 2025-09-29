variable "router_classification_class_name" {
  description = "The name of the classification class"
  type        = string
  default     = "class"
}

variable "router_classification_properties" {
  description = "The properties of the classification class"
  type        = list(string)
  default     = ["class", "confidence", "referenced_tool_call_ids"]
}
