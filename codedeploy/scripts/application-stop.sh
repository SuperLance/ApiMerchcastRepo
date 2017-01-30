#!/bin/bash

## ONLY USE THIS IF MORE THAN ONE NODE IN ASG
# if [ "$DEPLOYMENT_GROUP_NAME" == "onelive-prod-code-deploy-ApiGroup-9KH1VGAI2R3I" ]
# then
#     /usr/bin/aws elb deregister-instances-from-load-balancer --load-balancer-name lb-onelive-prod-elb-api --instances $(curl http://169.254.169.254/latest/meta-data/instance-id) --region=us-west-2
#     sleep 30
# fi

#TURN OFF  MONIT
/usr/bin/monit unmonitor unicorn

# #WAIT FOR MONIT
# while /bin/true; do

#     /usr/bin/monit summary | grep -q 'not monitored'

#     if [[ $? == 0 ]]; then
#         break
#     fi

#     sleep 5

# done;

#STOP UNICORN PROCESS IF RUNNING
/bin/kill -QUIT $(ps aux | grep '[u]nicorn_rails master' | awk '{print $2}') || true

sleep 3

rm /home/app.merchcast.com/cache/unicorn.pid || true
