#!/bin/bash

cd /var/www/html/app.merchcast.com/public
/usr/local/bin/bundle install --path vendor/bundle

# branch == staging
if [ "$DEPLOYMENT_GROUP_NAME" == "onelive-staging-code-deploy-ApiGroup-10HCHEUCKUST5" ]
then

    RAILS_ENV=development /usr/local/bin/bundle exec rake assets:precompile
    /usr/local/bin/bundle exec rake assets:precompile RAILS_ENV=development
    RAILS_ENV=development /usr/local/bin/bundle exec rake db:migrate
    RAILS_ENV=development /usr/local/bin/bundle exec rake db:seed
    RAILS_ENV=production /usr/local/bin/bundle exec rake db:migrate   
    RAILS_ENV=production /usr/local/bin/bundle exec rake db:seed
    /usr/local/bin/bundle exec rake assets:precompile

    ### START COMMAND
    export RAILS_START_CMD="/usr/local/bin/bundle exec unicorn_rails -E development -c config/unicorn.rb -D"

fi

### branch == prod   
if [ "$DEPLOYMENT_GROUP_NAME" == "onelive-prod-code-deploy-ApiGroup-9KH1VGAI2R3I" ]
then

    RAILS_ENV=development /usr/local/bin/bundle exec rake assets:precompile
    /usr/local/bin/bundle exec rake assets:precompile RAILS_ENV=production
    RAILS_ENV=development /usr/local/bin/bundle exec rake db:migrate
    RAILS_ENV=development /usr/local/bin/bundle exec rake db:seed
    RAILS_ENV=production /usr/local/bin/bundle exec rake db:migrate
    RAILS_ENV=production /usr/local/bin/bundle exec rake db:seed
    /usr/local/bin/bundle exec rake assets:precompile

    ### START COMMAND
    export RAILS_START_CMD="/usr/local/bin/bundle exec unicorn_rails -E production -c config/unicorn.rb -D"

fi

#RUN IT AND SAVE COMMAND FOR MONIT
cat << EOF > /home/app.merchcast.com/rails_start_monit   
 #!/bin/bash
 cd /var/www/html/app.merchcast.com/public && $RAILS_START_CMD
EOF
chmod +x /home/app.merchcast.com/rails_start_monit
/home/app.merchcast.com/rails_start_monit
