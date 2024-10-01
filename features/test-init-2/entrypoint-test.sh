#!/usr/bin/env -S bash --noprofile --norc -o errexit -o pipefail -o noclobber -o nounset

echo "Test Entry Point Running...."

TEST_INIT_LOG_FILE="/tmp/test-init-2.log"


touch $TEST_INIT_LOG_FILE
while true; do
    log_date=$(date)
    echo "[$log_date] Test Entry Point Running.... " >> $TEST_INIT_LOG_FILE
    sleep 5
done
