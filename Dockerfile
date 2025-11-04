FROM opensuse/tumbleweed

# Environment variables
ENV MEDIAWIKI_VERSION=1.39.15
ENV MEDIAWIKI_ARCHIVE=mediawiki-$MEDIAWIKI_VERSION.tar.gz
ENV MEDIAWIKI_URL=https://releases.wikimedia.org/mediawiki/1.39/$MEDIAWIKI_ARCHIVE
ENV MEDIAWIKI_DIR=/srv/www/htdocs

ENV MEDIAWIKI_SEMANTICRATING_URL https://extdist.wmflabs.org/dist/extensions/SemanticRating-REL1_39-2a49137.tar.gz

ENV SITE_URL=wiki.orians.org
ENV SITE_ALIAS_URL=wikibackup.orians.org
ENV SITE_FILENAME=lexielogo.png
ENV SITE_LOGO_URL=https://mediaassets.orians.org/lexielogo.png

# Install Apache, PHP, and dependencies
RUN zypper --non-interactive ref
RUN zypper --non-interactive install apache2 apache2-utils
RUN zypper --non-interactive install php8
RUN zypper --non-interactive install php8-APCu php8-cli php8-ctype php8-curl php8-dom php8-fileinfo php8-gd php8-gettext php8-iconv php8-intl php8-mbstring php8-mysql php8-openssl php8-pdo php8-pear php8-phar php8-posix php8-sqlite php8-sysvsem php8-tokenizer php8-xmlreader php8-xmlwriter php8-zip php8-zlib
RUN zypper --non-interactive install apache2-mod_php8
RUN zypper --non-interactive install wget
RUN zypper --non-interactive install tar
RUN zypper --non-interactive install vim

# Enable Apache PHP module
RUN a2enmod php8

# Download and install MediaWiki
RUN cd /tmp && \
    wget $MEDIAWIKI_URL && \
    tar -xvzf $MEDIAWIKI_ARCHIVE && \
    mv mediawiki-$MEDIAWIKI_VERSION/* $MEDIAWIKI_DIR && \
    rm -rf mediawiki-$MEDIAWIKI_VERSION $MEDIAWIKI_ARCHIVE

RUN cd /tmp && \
    wget $MEDIAWIKI_SEMANTICRATING_URL && \
    tar -xzf SemanticRating-REL1_39-2a49137.tar.gz -C $MEDIAWIKI_DIR/extensions 

RUN cd /tmp && \
    wget $SITE_LOGO_URL && \
    cp $SITE_FILENAME $MEDIAWIKI_DIR/resources/assets

# Set directory permissions
RUN chown -R wwwrun:www $MEDIAWIKI_DIR
RUN chmod -R 755 $MEDIAWIKI_DIR

# Setup VirtualHost for subdomain
RUN echo "<VirtualHost *:80>" > /etc/apache2/vhosts.d/wiki.conf && \
    echo "    ServerName $SITE_URL" >> /etc/apache2/vhosts.d/wiki.conf && \
    echo "    ServerAlias $SITE_ALIAS_URL" >> /etc/apache2/vhosts.d/wiki.conf && \
    echo "    DocumentRoot \"$MEDIAWIKI_DIR\"" >> /etc/apache2/vhosts.d/wiki.conf && \
    echo "    <Directory \"$MEDIAWIKI_DIR\">" >> /etc/apache2/vhosts.d/wiki.conf && \
    echo "        Options All" >> /etc/apache2/vhosts.d/wiki.conf && \
    echo "        AllowOverride All" >> /etc/apache2/vhosts.d/wiki.conf && \
    echo "    </Directory>" >> /etc/apache2/vhosts.d/wiki.conf && \
    echo "    ErrorLog /var/log/apache2/wiki-error.log" >> /etc/apache2/vhosts.d/wiki.conf && \
    echo "    CustomLog /var/log/apache2/wiki-access.log combined" >> /etc/apache2/vhosts.d/wiki.conf && \
    echo "</VirtualHost>" >> /etc/apache2/vhosts.d/wiki.conf

# Expose HTTP port
EXPOSE 80

CMD ["/usr/sbin/start_apache2", "-DFOREGROUND"]

