terraform {
  required_version = ">= 1.4.0"
}

variable "message" {
  description = "Message printed by local-exec. Change it to trigger terraform_data replacement."
  type        = string
  default     = "Hello from Terraform local-exec"
}

variable "run_script" {
  description = "If true, run the local shell script instead of the inline echo command."
  type        = bool
  default     = false
}

resource "terraform_data" "local_demo" {
  # Changing message replaces terraform_data and runs its creation-time provisioner again.
  triggers_replace = [var.message, var.run_script]

  provisioner "local-exec" {
    command = var.run_script ? "bash ${path.module}/scripts/local-setup.sh" : "echo ${jsonencode(var.message)}"
  }

  # Windows PowerShell popup example (interactive desktop only):
  # provisioner "local-exec" {
  #   interpreter = ["PowerShell", "-Command"]
  #   command     = "Add-Type -AssemblyName PresentationFramework; [System.Windows.MessageBox]::Show('Terraform ran local-exec')"
  # }
}

output "message_used" {
  value = var.message
}
