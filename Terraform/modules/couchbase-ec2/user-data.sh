#!/bin/bash
# COUCHBASE INSTALLATION SCRIPT FOR AMAZON LINUX 2
# Cluster: enutritrack
# Username: Admin
# Password: admin123
# Bucket: enutritrack (Couchbase type)

set -e

CLUSTER_NAME="enutritrack"
BUCKET_NAME="enutritrack"
CB_USERNAME="Admin"
CB_PASSWORD="admin123"

# Update system
yum update -y

# Install dependencies
yum install -y wget tar libev libuv lsof

# Download Couchbase Server (Community Edition 7.2.0)
wget https://packages.couchbase.com/releases/7.2.0/couchbase-server-community-7.2.0-linux.x86_64.rpm -O /tmp/couchbase.rpm

# Install Couchbase
rpm --install /tmp/couchbase.rpm

# Start Couchbase service
systemctl enable couchbase-server
systemctl start couchbase-server

# Wait for Couchbase to start (30-60 seconds)
sleep 60

# Configure Couchbase Cluster
/opt/couchbase/bin/couchbase-cli cluster-init -c localhost:8091 \
  --cluster-username="$CB_USERNAME" \
  --cluster-password="$CB_PASSWORD" \
  --services=data,index,query,fts \
  --cluster-ramsize=1024 \
  --cluster-index-ramsize=256 \
  --cluster-fts-ramsize=256

# Create bucket (Couchbase type)
/opt/couchbase/bin/couchbase-cli bucket-create -c localhost:8091 \
  --username="$CB_USERNAME" \
  --password="$CB_PASSWORD" \
  --bucket="$BUCKET_NAME" \
  --bucket-type=couchbase \
  --bucket-ramsize=256 \
  --enable-flush=1

echo "========================================="
echo "Couchbase Server installed successfully"
echo "Cluster: $CLUSTER_NAME"
echo "Admin URL: http://localhost:8091"
echo "Username: $CB_USERNAME"
echo "Password: $CB_PASSWORD"
echo "Bucket: $BUCKET_NAME (Couchbase type)"
echo "========================================="