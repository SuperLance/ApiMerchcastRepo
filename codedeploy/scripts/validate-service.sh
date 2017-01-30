#!/bin/bash

#MONITOR MONIT
/usr/bin/monit monitor unicorn

## ONLY USE THIS IF MORE THAN ONE NODE IN ASG
# if [ "$DEPLOYMENT_GROUP_NAME" == "onelive-prod-code-deploy-ApiGroup-9KH1VGAI2R3I" ]
# then

#     /usr/bin/aws elb register-instances-with-load-balancer --load-balancer-name lb-onelive-prod-elb-api --instances $(curl http://169.254.169.254/latest/meta-data/instance-id) --region=us-west-2

#     while /bin/true; do

#         /usr/bin/aws elb describe-instance-health --load-balancer-name lb-onelive-prod-elb-api --instances $(curl http://169.254.169.254/latest/meta-data/instance-id) --region=us-west-2 | grep -q '"InService"'

#         if [[ $? == 0 ]]; then
#             exit 0;
#         fi

#         sleep 15

#     done;

# fi
