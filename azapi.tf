data "azapi_resource" "spot" {
  name = "vm_spot"
  type = "Microsoft.Compute/virtualMachines@2024-07-01"
} 

resource "local_file" "name" {
  content = data.azapi_resource.spot.
}