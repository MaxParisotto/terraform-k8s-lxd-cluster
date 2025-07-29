provider "juju" {}

resource "juju_model" "k8s_model" {
  name = "maas-cloud"
  cloud {
    name = "maas-cloud"
  }
}

resource "juju_application" "k8s_bundle" {
  name    = "charmed-kubernetes"
  model   = juju_model.k8s_model.name
  charm {
    name = "charmed-kubernetes"
  }
  # Place all units using explicit Juju machine numbers
  # Example: "0,1,2,3,4,5,6,7" for 8 machines (adjust as needed)
  placement = "0,1,2,3,4,5,6,7"
  # Ensure the order matches: first 4 are control-planes, next 4 are workers
}

resource "juju_application" "vault" {
  name    = "vault"
  model   = juju_model.k8s_model.name
  charm {
    name = "vault"
  }
  # Place vault on the next available machine (e.g., 8)
  placement = "8"
}

# Example: add overlay YAML for Vault as CA (if needed)
# resource "juju_bundle" "vault_overlay" {
#   model   = juju_model.k8s_model.name
#   overlay = file("vault-overlay.yaml")
# }

# Example: add relations (integrations) between applications
# resource "juju_integration" "vault_certificates" {
#   model = juju_model.k8s_model.name
#   application_1 = juju_application.vault.name
#   application_2 = juju_application.k8s_bundle.name
#   endpoint_1 = "certificates"
#   endpoint_2 = "certificates"
# }

# Adjust the above as needed for your actual Juju controller, user, and bundle/overlay details.
