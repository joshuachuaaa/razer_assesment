#!/bin/bash

# Step 1: Pull Docker Registry
docker pull registry:2

# Step 2: Run Docker Registry with S3 storage
docker run -d --name registry -p 5000:5000 \
  -e REGISTRY_STORAGE=s3 \
  -e REGISTRY_STORAGE_S3_BUCKET=razer-assesment-bucket \
  -e REGISTRY_STORAGE_S3_REGION=ap-southeast-2 \
  -e AWS_ACCESS_KEY_ID=<your-access-key> \
  -e AWS_SECRET_ACCESS_KEY=<your-secret-key> \
  registry:2

# Step 3: Pull test app image
docker pull yeasy/simple-web

# Step 4: Tag and push to private registry
docker tag yeasy/simple-web localhost:5000/simple-web
docker push localhost:5000/simple-web

# Step 5: Create Docker network
docker network create webnet

# Step 6: Run two app containers (for load balancing)
docker run -d --name simple-web-1 --network webnet localhost:5000/simple-web
docker run -d --name simple-web-2 --network webnet localhost:5000/simple-web

# Step 7: Prepare nginx.conf (see code in file)

# Step 8: Run Nginx with load balancing
docker run -d --name nginx-proxy --network webnet -p 80:80 \
  -v $(pwd)/nginx.conf:/etc/nginx/nginx.conf:ro nginx

echo "✅ Setup complete! Visit http://localhost to test."
