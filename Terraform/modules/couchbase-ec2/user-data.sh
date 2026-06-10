#!/bin/bash
set -e

CLUSTER_NAME="enutritrack"
BUCKET_NAME="enutritrack"
CB_USERNAME="Admin"
CB_PASSWORD="admin123"

echo "========================================="
echo "Installing Couchbase..."
echo "========================================="

# Update system
yum update -y

# Dependencies
yum install -y wget tar curl libev libuv lsof

# Install Couchbase
wget https://packages.couchbase.com/releases/7.2.0/couchbase-server-community-7.2.0-linux.x86_64.rpm -O /tmp/couchbase.rpm
rpm --install /tmp/couchbase.rpm

# Enable service
systemctl enable couchbase-server
systemctl start couchbase-server

echo "Waiting Couchbase service..."

# 🔥 WAIT REAL: API health endpoint
for i in {1..90}; do
  if curl -s http://127.0.0.1:8091/pools >/dev/null; then
    echo "Couchbase is responding"
    break
  fi
  echo "Waiting Couchbase... ($i)"
  sleep 5
done

PRIVATE_IP=$(curl -s http://169.254.169.254/latest/meta-data/local-ipv4)

echo "Private IP: $PRIVATE_IP"

COUCHBASE_CLI="/opt/couchbase/bin/couchbase-cli"

# =========================
# NODE INIT
# =========================
echo "Initializing node..."

$COUCHBASE_CLI node-init \
  -c 127.0.0.1:8091 \
  --node-init-hostname="$PRIVATE_IP" || true

# =========================
# CLUSTER INIT (only if not initialized)
# =========================
echo "Checking cluster status..."

if curl -s http://127.0.0.1:8091/pools | grep -q '"clusterName"'; then
  echo "Cluster already initialized"
else
  echo "Creating cluster..."

  $COUCHBASE_CLI cluster-init \
    -c 127.0.0.1:8091 \
    --cluster-username="$CB_USERNAME" \
    --cluster-password="$CB_PASSWORD" \
    --services=data,index,query,fts \
    --cluster-ramsize=1024 \
    --cluster-index-ramsize=256 \
    --cluster-fts-ramsize=256
fi

# =========================
# CREATE BUCKET (idempotent)
# =========================
echo "Checking bucket..."

BUCKET_EXISTS=$($COUCHBASE_CLI bucket-list \
  -c 127.0.0.1:8091 \
  -u "$CB_USERNAME" \
  -p "$CB_PASSWORD" | grep "$BUCKET_NAME" || true)

if [ -z "$BUCKET_EXISTS" ]; then
  echo "Creating bucket..."

  $COUCHBASE_CLI bucket-create \
    -c 127.0.0.1:8091 \
    -u "$CB_USERNAME" \
    -p "$CB_PASSWORD" \
    --bucket="$BUCKET_NAME" \
    --bucket-type=couchbase \
    --bucket-ramsize=256 \
    --enable-flush=1
else
  echo "Bucket already exists"
fi

echo "========================================="
echo "Couchbase READY"
echo "Cluster: $CLUSTER_NAME"
echo "URL: http://$PRIVATE_IP:8091"
echo "User: $CB_USERNAME"
echo "Bucket: $BUCKET_NAME"
echo "========================================="