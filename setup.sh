#!/bin/bash

echo "Setting up environment..."

# Check if Docker is installed
if ! command -v docker &> /dev/null
then
    echo "Docker not found! Please install Docker first."
    exit 1
fi

# Check if Docker Compose is installed
if ! command -v docker compose &> /dev/null
then
    echo "Docker Compose not found! Please install Docker Compose."
    exit 1
fi

echo "Starting Docker Compose services..."
docker compose up -d

echo "Waiting 10 seconds for services to start..."
sleep 10

echo "Current service status:"
docker ps --format "table {{.Names}}\t{{.Status}}"

# Sample App
echo "Checking Sample App..."
for i in {1..5}; do
    sample_status=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:3000)
    if [ "$sample_status" -eq 200 ]; then
        sample_output=$(curl -s http://localhost:3000)
        echo "Sample App is running (HTTP $sample_status)"
        echo "Sample App output: $sample_output"
        break
    else
        echo "Sample App not ready yet, retrying..."
        sleep 3
    fi
done

echo "Checking Nginx..."
nginx_status=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:80)
if [ "$nginx_status" -eq 200 ]; then
    echo "Nginx is running (HTTP $nginx_status)"
else
    echo "Nginx check failed (HTTP $nginx_status)"
fi

# Health check: Redis
echo "Checking Redis..."
for i in {1..5}; do
    redis_status=$(docker exec redis redis-cli ping)
    if [ "$redis_status" == "PONG" ]; then
        echo "Redis is running ($redis_status)"
        break
    else
        echo "Redis not ready yet, retrying..."
        sleep 2
    fi
done

echo "Setup completed!"
