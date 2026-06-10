# ENVIRONMENT VARIABLES FOR ENUTRITRACK MICROSERVICES
# Este template se puede usar para generar archivos .env

NODE_ENV=${environment}
PORT=${container_port}

# PostgreSQL
DB_HOST=${db_host}
DB_PORT=${db_port}
DB_NAME=${db_name}
DB_USER=${db_user}
DB_PASSWORD=${db_password}

# Redis
REDIS_HOST=${redis_host}
REDIS_PORT=${redis_port}

# Couchbase
COUCHBASE_HOST=${couchbase_host}
COUCHBASE_PORT=8091
COUCHBASE_BUCKET=enutritrack

# JWT
JWT_SECRET=${jwt_secret}

# Gemini API Key
GEMINI_API_KEY=${gemini_api_key}