#!/bin/bash

APP_NAME="blue-cherry-6374"
NEW_REGION="dfw"

echo 'y' | fly config save --app $APP_NAME
sed -i'' -e "s/primary_region =.*/primary_region = \"$NEW_REGION\"/" fly.toml
sed -i'' -e "s/PRIMARY_REGION =.*/PRIMARY_REGION = \"$NEW_REGION\"/" fly.toml
fly deploy . --app $APP_NAME --image flyio/postgres-flex:15.6 --strategy=immediate

# Wait for deployment indicators to stabilize
echo "Monitoring deployment stabilization..."
while : ; do
    STATUS_OUTPUT=$(fly status --app $APP_NAME | grep -c '3 total, 3 passing')
    if [ "$STATUS_OUTPUT" -gt 0 ]; then
        echo "Initial stabilization detected, proceeding with failover checks..."
        break
    else
        echo "Waiting for initial deployment stabilization..."
        sleep 4
    fi
done

# Initiate failover
fly pg failover --app $APP_NAME

# Monitor for full stabilization
echo "Monitoring for full stabilization post-failover..."
while : ; do
    STATUS_OUTPUT=$(fly status --app $APP_NAME)
    if echo "$STATUS_OUTPUT" | grep -qe 'error' -e 'warning'; then
        echo "Instances still stabilizing..."
    else
        PASSING_CHECKS=$(echo "$STATUS_OUTPUT" | grep -c '3 total, 3 passing')
        EXPECTED_COUNT=9
        if [ "$PASSING_CHECKS" -eq "$EXPECTED_COUNT" ]; then
            echo "All instances stabilized and in passing state."
            break
        else
            echo "Waiting for all instances to reach passing state..."
        fi
    fi
    sleep 4
done
