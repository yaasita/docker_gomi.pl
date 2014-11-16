FROM ubuntu:14.04
MAINTAINER yaasita

#apt
ADD 02proxy /etc/apt/apt.conf.d/02proxy
RUN apt-get update
RUN apt-get upgrade -y

#package
RUN apt-get install -y git \
 aptitude htop vim dnsutils

#postfix
RUN apt-get install -y postfix
COPY etc/postfix/main.cf /etc/postfix/main.cf

#ssh
RUN apt-get install -y openssh-server
RUN mkdir /var/run/sshd/
RUN mkdir /root/.ssh
ADD authorized_keys /root/.ssh/authorized_keys
RUN perl -i -ple 's/^(permitrootlogin\s)(.*)/\1yes/i' /etc/ssh/sshd_config
RUN echo root:root | chpasswd
EXPOSE 22
CMD /usr/sbin/sshd -D

# supervisor
RUN apt-get install -y supervisor
ADD supervisord.conf /etc/supervisor/conf.d/supervisord.conf
EXPOSE 22 80
CMD ["/usr/bin/supervisord"]

# locale
RUN apt-get install -y locales language-pack-ja
COPY etc/default/locale /etc/default/locale
COPY etc/localtime /etc/localtime
COPY etc/timezone /etc/timezone

# cron
RUN rm /etc/cron.weekly/*
COPY etc/crontab /etc/crontab

# gomi.pl
RUN cd /root && git clone https://github.com/yaasita/gomi.pl.git
COPY etc/cron.weekly/gomi /etc/cron.weekly/gomi
RUN chmod +x /etc/cron.weekly/gomi
