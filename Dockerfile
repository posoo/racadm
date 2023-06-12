FROM debian:bullseye as converter
COPY iDRACTools /idrac
RUN apt update
RUN apt install -y alien
WORKDIR /idrac/racadm/RHEL8/x86_64
RUN alien *.rpm

FROM debian:bullseye
WORKDIR /idrac
COPY --from=converter /idrac/racadm/RHEL8/x86_64/*.deb /idrac/
RUN dpkg -i *.deb
RUN ln -s /opt/dell/srvadmin/bin/idracadm7 /usr/local/bin/idracadm7
RUN ln -s /usr/local/bin/idracadm7 /usr/local/bin/racadm
RUN ln -s /usr/lib/x86_64-linux-gnu/libssl.so.1.1 /usr/lib/x86_64-linux-gnu/libssl.so
