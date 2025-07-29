
provider "maas" {
  api_version         = "2.0"
  api_key             = "wZaVDgSiTL9Qi6xy1Y:iAQtxbsRC7CDEVWER4:LgzJQLZHDXPar9e6uhLGv7XjhrkDlBNf"
  api_url             = "http://172.16.0.100:5240/MAAS/"
  installation_method = "snap"
}

# All VM and deployment resources should now be managed in vms.tf using the MAAS provider only.