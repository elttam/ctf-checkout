# :latest isn't latest, but should be fixed soon - https://github.com/phusion/passenger-docker/issues/197
FROM phusion/passenger-ruby24:latest

RUN rm -f /etc/service/nginx/down
RUN rm /etc/nginx/sites-enabled/default
ADD nginx/app.conf /etc/nginx/sites-enabled/app.conf

COPY webapp/ /home/app/webapp
RUN chown -R app:app /home/app/
USER app
RUN bundle install --gemfile /home/app/webapp/Gemfile
USER root

CMD ["/sbin/my_init"]
