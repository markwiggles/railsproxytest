# Adapted from https://intercityup.com/blog/deploy-rails-app-including-database-configuration-env-vars-assets-using-docker.html

FROM phusion/passenger-ruby22:latest

# Set correct environment variables.
ENV HOME /root
ENV RAILS_ENV production

# Use baseimage-docker's init process.
CMD ["/sbin/my_init"]

# Start Nginx / Passenger
RUN rm -f /etc/service/nginx/down

# Prepare folders
RUN mkdir /home/app/webapp

# Copy the Gemfile and Gemfile.lock into the image.
# Temporarily set the working directory to where they are.
WORKDIR /tmp
ADD railsapp/Gemfile Gemfile
ADD railsapp/Gemfile.lock Gemfile.lock
RUN bundle install

# Remove the default site & add the nginx info for our site
RUN rm /etc/nginx/sites-enabled/default
ADD nginx/webapp.conf /etc/nginx/sites-enabled/webapp.conf

# Add the rails app
ADD railsapp /home/app/webapp

# change ownership to the app user for passenger and create log file
RUN chown -R app:app /home/app/webapp
RUN chmod 664 -R /home/app/webapp/log/production.log

WORKDIR /home/app/webapp
RUN RAILS_ENV=production bundle exec rake assets:precompile
EXPOSE 80

# Clean up when done.
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /var/tmp/*
