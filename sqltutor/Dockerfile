FROM httpd:2.4-bookworm

RUN apt-get update
RUN apt-get -y install git autoconf g++ make libpqxx-dev texinfo postgresql-client

WORKDIR /opt
RUN git clone git://git.savannah.gnu.org/sqltutor.git
RUN git clone git://git.sv.gnu.org/sqltutor/datasets.git

RUN sed -i 's/psql/psql -h db -U postgres/g' datasets/configure.ac
RUN sed -i 's/psql/psql -h db -U postgres/g' sqltutor/database/Makefile.am
RUN sed -i 's/host=localhost/host=db/g'      sqltutor/cgi.cpp/settings.cpp

COPY sqltutor-installer.sh start.sh ./
RUN chmod 744 start.sh sqltutor-installer.sh

COPY sqltutor.conf /usr/local/apache2/conf/
RUN echo "Include /usr/local/apache2/conf/sqltutor.conf" \
    >> /usr/local/apache2/conf/httpd.conf

# run start script
ENTRYPOINT ["/bin/bash", "/opt/start.sh"]
