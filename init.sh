#!/bin/bash
set -e

# -------------------- Configurações --------------------
BASE_DIR="$(cd "$(dirname "$0")" && pwd)"
CERT_DIR="$BASE_DIR/certs"
VAULT_FILE_DIR="$BASE_DIR/ansible/vault_playbook/roles/vault/files"
VAULT_UNSEAL_LEADER_FILE_DIR="$BASE_DIR/ansible/vault_unseal_playbook/leader/roles/unseal/files"
VAULT_UNSEAL_FOLLOWERS_FILE_DIR="$BASE_DIR/ansible/vault_unseal_playbook/followers/roles/unseal/files"



mkdir -p "$CERT_DIR"
mkdir -p "$VAULT_FILE_DIR"
mkdir -p "$VAULT_UNSEAL_FILE_DIR"
cd "$CERT_DIR"

echo "Gerando certificados em: $CERT_DIR"

# -------------------- Gerar CA raiz --------------------
echo "Gerando CA raiz..."
openssl genrsa -out ca.key 4096

cat > ca_ext.cnf <<EOF
[ v3_ca ]
basicConstraints = CA:TRUE
keyUsage = keyCertSign, cRLSign
subjectKeyIdentifier = hash
EOF

openssl req -x509 -new -nodes -sha256 -days 3650 \
  -key ca.key -out ca.pem -subj "/C=BR/ST=RJ/O=MyOrg/CN=Vault-CA" \
  -extensions v3_ca -config ca_ext.cnf

# -------------------- Função para gerar certificado de cada nó --------------------
generate_cert() {
  NODE_NAME=$1
  NODE_IP=$2

  echo "Gerando chave privada para $NODE_NAME..."
  openssl genrsa -out ${NODE_NAME}.key 2048

  cat > ${NODE_NAME}_ext.cnf <<EOF
[ req ]
default_bits       = 2048
prompt             = no
default_md         = sha256
distinguished_name = dn
req_extensions     = req_ext

[ dn ]
C=BR
ST=RJ
L=Rio
O=MyOrg
OU=Vault
CN=${NODE_NAME}.local

[ req_ext ]
subjectAltName = @alt_names

[ alt_names ]
DNS.1 = ${NODE_NAME}.local
IP.1  = ${NODE_IP}
EOF

  echo "Gerando CSR para $NODE_NAME..."
  openssl req -new -key ${NODE_NAME}.key -out ${NODE_NAME}.csr -config ${NODE_NAME}_ext.cnf

  echo "Assinando CSR para $NODE_NAME..."
  openssl x509 -req -in ${NODE_NAME}.csr -CA ca.pem -CAkey ca.key -CAcreateserial \
    -out ${NODE_NAME}.crt -days 365 -sha256 -extensions req_ext -extfile ${NODE_NAME}_ext.cnf
}

# -------------------- Gerar para cada nó --------------------
generate_cert vault-node1 192.168.122.11
generate_cert vault-node2 192.168.122.12
generate_cert vault-node3 192.168.122.13

\cp "$CERT_DIR"/* "$VAULT_FILE_DIR"
\cp "$CERT_DIR/ca.pem" "$VAULT_UNSEAL_LEADER_FILE_DIR"
\cp "$CERT_DIR/ca.pem" "$VAULT_UNSEAL_LEADER_FILE_DIR"
\cp "$CERT_DIR/ca.pem" "$VAULT_UNSEAL_FOLLOWERS_FILE_DIR"

# -------------------- Listar certificados --------------------
echo "Certificados gerados:"
ls -l *.key *.crt ca.pem
