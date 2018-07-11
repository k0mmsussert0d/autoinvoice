FROM nimmis/apache-php7
WORKDIR /var/www/html
ADD . /var/www/html
RUN apt-get update && apt-get install -y bc \
gcc \
mutt
EXPOSE 80
