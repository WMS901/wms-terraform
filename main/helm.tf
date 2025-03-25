# resource "helm_release" "mongo_inbound" {
#   name       = "mongo-inbound"
#   namespace  = "default"
#   chart      = "${path.module}/../modules/helm/databases/mongo-inbound"
#   version    = "0.1.0"
#   values     = [file("${path.module}/../modules/helm/databases/mongo-inbound/values.yaml")]
#   depends_on = [module.eks]
# }