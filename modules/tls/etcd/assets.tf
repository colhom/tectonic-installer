resource "local_file" "etcd_client_cert" {
  content  = "${tls_locally_signed_cert.etcd_client.cert_pem}"
  filename = "./generated/tls/etcd-client.crt"
}

resource "local_file" "etcd_client_key" {
  content  = "${tls_private_key.etcd_client.private_key_pem}"
  filename = "./generated/tls/etcd-client.key"
}

resource "local_file" "etcd_server_cert" {
  content  = "${tls_locally_signed_cert.etcd_server.cert_pem}"
  filename = "./generated/tls/etcd/server.crt"
}

resource "local_file" "etcd_server_key" {
  content  = "${tls_private_key.etcd_server.private_key_pem}"
  filename = "./generated/tls/etcd/server.key"
}

resource "local_file" "etcd_peer_cert" {
  content  = "${tls_locally_signed_cert.etcd_peer.cert_pem}"
  filename = "./generated/tls/etcd/peer.crt"
}

resource "local_file" "etcd_peer_key" {
  content  = "${tls_private_key.etcd_peer.private_key_pem}"
  filename = "./generated/tls/etcd/peer.key"
}
