#!/bin/bash
set -e

# ======================
# VARIABLES
# ======================
CA_KEY="caIot.key"
CA_CERT="caIot.crt"
CA_CNF="ca.cnf"

SERVER_KEY="serverIot_30.key"
SERVER_CSR="serverIot_30.csr"
SERVER_CERT="serverIot_30.crt"
SERVER_CNF="server.cnf"

CLIENT_KEY="clientIot.key"
CLIENT_CSR="clientIot.csr"
CLIENT_CERT="clientIot.crt"
CLIENT_CNF="client.cnf"

CA_CN="CA_Broce"
SERVER_CN="serv_Iot.com"
SERVER_IP="192.168.1.116"
CLIENT_CN="clientIot"

# ======================
# CONFIG CA
# ======================
cat > $CA_CNF <<EOF
[ req ]
default_bits       = 4096
distinguished_name = dn
x509_extensions    = v3_ca
prompt             = no

[ dn ]
CN = $CA_CN

[ v3_ca ]
basicConstraints = critical, CA:TRUE
keyUsage = critical, keyCertSign, cRLSign
subjectKeyIdentifier = hash
EOF
# Création du CA (décommentez si nécessaire)
echo "Création de la clé privée de la CA..."
openssl genrsa -out $CA_KEY 4096
echo "Création du certificat auto-signé de la CA..."
openssl req -new -x509 -key $CA_KEY -days 3650 -sha256 -out $CA_CERT -config $CA_CNF

# --------------------
# Partie Serveur
# --------------------
# ======================
# CONFIG SERVEUR
# ======================
cat > $SERVER_CNF <<EOF
[ req ]
default_bits       = 2048
distinguished_name = dn
req_extensions     = v3_req
prompt             = no

[ dn ]
CN = $SERVER_CN

[ v3_req ]
basicConstraints = CA:FALSE
keyUsage = critical, digitalSignature, keyEncipherment
extendedKeyUsage = serverAuth
subjectAltName = @alt_names

[ alt_names ]
DNS.1 = $SERVER_CN
IP.1  = $SERVER_IP
EOF
echo "Création de la clé privée du serveur..."
openssl genrsa -out $SERVER_KEY 2048
echo "Création de la demande de certificat du serveur..."
openssl req -new -key $SERVER_KEY -out $SERVER_CSR -config $SERVER_CNF
echo "Signature du certificat serveur avec la CA..."
openssl x509 -req -in $SERVER_CSR -CA $CA_CERT -CAkey $CA_KEY -CAcreateserial -out $SERVER_CERT \
  -days 365 -sha256 -extensions v3_req -extfile $SERVER_CNF

# --------------------
# Partie Client
# --------------------
# ======================
# CONFIG CLIENT
# ======================
cat > $CLIENT_CNF <<EOF
[ req ]
default_bits       = 2048
distinguished_name = dn
req_extensions     = v3_req
prompt             = no

[ dn ]
CN = $CLIENT_CN

[ v3_req ]
basicConstraints = CA:FALSE
keyUsage = critical, digitalSignature
extendedKeyUsage = clientAuth
EOF
echo "Création de la clé privée du client..."
openssl genrsa -out $CLIENT_KEY 2048
echo "Création de la demande de certificat du client..."
openssl req -new -key $CLIENT_KEY -out $CLIENT_CSR -config $CLIENT_CNF
echo "Signature du certificat client avec la CA..."
openssl x509 -req -in $CLIENT_CSR -CA $CA_CERT -CAkey $CA_KEY -out $CLIENT_CERT  -days 365 -sha256 -extensions v3_req -extfile $CLIENT_CNF


echo "Fin"
