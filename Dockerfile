FROM centos/s2i-base-centos7

EXPOSE 80

LABEL maintainer="Damian Dragowski<damian.dragowski@gmail.com>"

ENV NGINX_VERSION=1.17.9 \
    NAME=nginx

ENV SUMMARY="Platform for running Nginx web server to host assets" \
    DESCRIPTION="Nginx $NODEJS_VERSION docker container for hosting assets."

LABEL summary="$SUMMARY" \
      description="$DESCRIPTION" \
      io.k8s.description="$DESCRIPTION" \
      io.k8s.display-name="Nginx $NGINX_VERSION" \
      io.openshift.expose-services="80:http" \
      io.openshift.tags="builder,$NAME,$NAME$NGINX_VERSION" \
      io.openshift.s2i.scripts-url="image:///usr/libexec/s2i" \
      io.s2i.scripts-url="image:///usr/libexec/s2i"

RUN wget http://nginx.org/download/nginx-$NGINX_VERSION.tar.gz \
    && tar -xvf nginx-$NGINX_VERSION.tar.gz \
    && cd nginx-$NGINX_VERSION \
    && ./configure \
    && make \
    && make install

ENV PATH=/usr/local/nginx/sbin/:$PATH

COPY ./s2i/bin/ /usr/libexec/s2i
COPY ./s2i/nginx.conf /usr/local/nginx/conf/nginx.conf

ENV NGINX_DIR /usr/local/nginx

RUN touch ${NGINX_DIR}/logs/error.log \
    && touch ${NGINX_DIR}/logs/access.log \
    && chown -R 1001:0 $NGINX_DIR \
    && chmod -R a+rwx ${NGINX_DIR}/logs \
    && chmod -R ug+rwx ${NGINX_DIR}

RUN chown -R 1001:1001 /opt/app-root

USER 1001

CMD ["/usr/libexec/s2i/usage"]
