FROM alpine
RUN apk --no-cache add ca-certificates wget
RUN wget -q -O /etc/apk/keys/sgerrand.rsa.pub https://alpine-pkgs.sgerrand.com/sgerrand.rsa.pub
RUN wget https://github.com/sgerrand/alpine-pkg-glibc/releases/download/2.28-r0/glibc-2.28-r0.apk
RUN apk add glibc-2.28-r0.apk
RUN mkdir /opt
ADD jre-8u181-linux-x64.tar.gz /opt
ADD helloworld.war /usr/local/bin
CMD /opt/jre1.8.0_181/bin/java -jar /usr/local/bin/helloworld.war