#!/bin/bash
if [[ ! -d ./.git ]]; then
	echo "You're not in the root of the repo!"
	exit 1
fi

rm ./.git/hooks/pre-push || true
ln -s ../../codedeploy/assets/pre-push ./.git/hooks/pre-push

git config codedeploy.awk-path /usr/bin/awk
git config codedeploy.head-path /usr/bin/head
git config codedeploy.aws-path /usr/local/bin/aws

git config codedeploy.source ./

git config codedeploy.staging.profile codedeploy.onelive.staging
git config codedeploy.staging.active 1
git config codedeploy.staging.s3bucket onelive-staging-s3-codedeploy-7zrptemhd618
git config codedeploy.staging.branch staging
git config codedeploy.staging.application-name onelive-staging-code-deploy-Api-OLNLU0BPWBGK
git config codedeploy.staging.deployment-group onelive-staging-code-deploy-ApiGroup-10HCHEUCKUST5
git config codedeploy.staging.disable-scaling 0

git config codedeploy.master.profile codedeploy.onelive.prod
git config codedeploy.master.active 1
git config codedeploy.master.s3bucket onelive-prod-s3-codedeploy-sx9rjfg4804e
git config codedeploy.master.branch master
git config codedeploy.master.application-name onelive-prod-code-deploy-Api-NKGISK1GAP33
git config codedeploy.master.deployment-group onelive-prod-code-deploy-ApiGroup-9KH1VGAI2R3I
git config codedeploy.master.disable-scaling 0
git config codedeploy.master.asg-name onelive-prod-asg-front-AutoscalingGroup-1B1P62J9ROL0T

echo "Git config loaded!"
