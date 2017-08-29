#!/bin/bash
set -euo pipefail

#!/bin/bash
set -e

REGION=`wget -q -O - http://169.254.169.254/latest/meta-data/placement/availability-zone | sed s'/[a-zA-Z]$//'`
INSTANCE_ID=`wget -q -O - http://169.254.169.254/latest/meta-data/instance-id`

/usr/bin/rkt run \
    --dns=host --net=host --trust-keys-from-https --interactive \
    --set-env=AWS_DEFAULT_REGION=$REGION \
    ${awscli_image} \
    -- \
      aws ec2 modify-instance-attribute \
      --instance-id=$INSTANCE_ID \
      --no-source-dest-check

exit 0
