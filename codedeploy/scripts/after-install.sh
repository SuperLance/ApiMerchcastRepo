# branch == staging
if [ "$DEPLOYMENT_GROUP_NAME" == "onelive-staging-code-deploy-ApiGroup-10HCHEUCKUST5" ]
then
    # Copy secrets files from S3
    /usr/bin/aws s3 cp s3://onelive-staging-s3-codedeploy-7zrptemhd618/secret/secrets.staging.yml /var/www/html/app.merchcast.com/public/config/secrets.yml
    /usr/bin/aws s3 cp s3://onelive-staging-s3-codedeploy-7zrptemhd618/secret/database.staging.yml /var/www/html/app.merchcast.com/public/config/database.yml
fi

# branch == prod
if [ "$DEPLOYMENT_GROUP_NAME" == "onelive-prod-code-deploy-ApiGroup-9KH1VGAI2R3I" ]
then
    # Copy secrets files from S3
    /usr/bin/aws s3 cp s3://onelive-staging-s3-codedeploy-7zrptemhd618/secret/secrets.prod.yml /var/www/html/app.merchcast.com/public/config/secrets.yml
    /usr/bin/aws s3 cp s3://onelive-staging-s3-codedeploy-7zrptemhd618/secret/database.prod.yml /var/www/html/app.merchcast.com/public/config/database.yml
fi

#ALL TO APP USER
chown -R app.merchcast.com:app.merchcast.com /var/www/html/app.merchcast.com