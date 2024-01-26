FROM sagcr.azurecr.io/webmethods-microservicesruntime:10.15.0.7

ADD --chown=sagadmin:sagadmin wpm /opt/softwareag/wpm
RUN chmod u+x /opt/softwareag/wpm/bin/wpm.sh
ENV PATH=/opt/softwareag/wpm/bin:$PATH

ARG WPM_TOKEN
ENV WPM_TOKEN=$WPM_TOKEN

WORKDIR /opt/softwareag/wpm
RUN /opt/softwareag/wpm/bin/wpm.sh install -ws https://packages.softwareag.com -wr softwareag -j $WPM_TOKEN -d /opt/softwareag/IntegrationServer WmJDBCAdapter
WORKDIR /

WORKDIR /opt/softwareag/IntegrationServer/packages/WmJDBCAdapter/code/jars
RUN curl -O https://jdbc.postgresql.org/download/postgresql-42.7.1.jar
WORKDIR /