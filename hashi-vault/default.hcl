storage "file" {
  path = "/vault/files"
}

ui = true

listener "tcp" {
  address     = "0.0.0.0:8200"
  tls_disable = 1
}

telemetry {
  prometheus_retention_time = "30s",
  disable_hostname = true
}