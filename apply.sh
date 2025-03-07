
# Apply Media Stack Plan 
cd terraform-media-stack
terraform init
terraform apply -target=null_resource.deployment -auto-approve
terraform apply -auto-approve
cd ..

