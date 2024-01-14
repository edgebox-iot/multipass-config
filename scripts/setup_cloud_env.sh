# Copy the temp file to the cloud instance
# Path: /tmp/cloud.env

multipass transfer ./scripts/cloud.env $1:/home/ubuntu/cloud.env

echo "Finished setting up cloud environment"