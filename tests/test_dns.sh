#!/bin/bash
set -e

# Test DNS resolution from within the test-client container
echo "Testing DNS resolution..."
if ! docker-compose exec -T test-client ping -c 1 example-web > /dev/null; then
    echo "❌ Failed to resolve example-web"
    exit 1
fi

if ! docker-compose exec -T test-client ping -c 1 example.local > /dev/null; then
    echo "❌ Failed to resolve example.local"
    exit 1
fi

echo "Testing web service accessibility..."
# Install curl in test container if not present
docker-compose exec -T test-client sh -c 'command -v curl || apk add --no-cache curl'

# Test web service via container name
if ! docker-compose exec -T test-client curl -s http://example-web | grep -q "Welcome to nginx"; then
    echo "❌ Failed to access web service via container name"
    exit 1
fi

# Test web service via custom domain
if ! docker-compose exec -T test-client curl -s http://example.local | grep -q "Welcome to nginx"; then
    echo "❌ Failed to access web service via custom domain"
    exit 1
fi

echo "✅ All tests passed!"
