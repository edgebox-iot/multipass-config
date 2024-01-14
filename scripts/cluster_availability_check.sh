#  Check the first 4 input arguments of this script. If any of them is empty, abort
if [ -z "$1" ] || [ -z "$2" ] || [ -z "$3" ] || [ -z "$4" ]; then
    echo "Missing arguments. Aborting."
    exit 1
fi

# Write a temp file: /tmp/cloud.env
# If file already exists, abort.
if [ -f ./scripts/cloud.env ]; then
    echo "Cloud environment being setup for another instance. Aborting."
    exit 1
fi

echo "Locking cluster..."
touch ./scripts/cloud.env
# Write to the temp file the following lines:
# USERNAME - argument 2
# CLUSTER - argument 4
# CLUSTER_IP - argument 5
# CLUSTER_SSH_PORT - argument 6

# If any of these is missing, abort.

echo "USERNAME=$1" >> ./scripts/cloud.env
echo "CLUSTER=$2" >> ./scripts/cloud.env
echo "CLUSTER_IP=$3" >> ./scripts/cloud.env
echo "CLUSTER_SSH_PORT=$4" >> ./scripts/cloud.env
