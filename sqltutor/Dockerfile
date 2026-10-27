FROM httpd:2.4-bookworm

RUN apt-get update \
    && apt-get -y install git autoconf g++ make libpqxx-dev texinfo postgresql-client \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /opt
RUN git clone https://git.savannah.gnu.org/git/sqltutor.git \
    && git -C sqltutor checkout 06d661e4c95ccab773fbc7d5cfbc355891901608
RUN git clone https://git.savannah.gnu.org/git/sqltutor/datasets.git \
    && git -C datasets checkout bf02dbc5c9d3f97e2b82b50d8fdd5797a586ad0c

RUN sed -i 's/psql/psql -h db -U postgres/g' datasets/configure.ac
RUN sed -i 's/psql/psql -h db -U postgres/g' sqltutor/database/Makefile.am
RUN sed -i 's/host=localhost/host=db/g'      sqltutor/cgi.cpp/settings.cpp

# generate configure scripts (credentials are set by installer at runtime)
RUN cd sqltutor && rm -f configure && ./autogen.sh
RUN cd datasets && rm -f configure && ./autogen.sh

COPY sqltutor-installer.sh start.sh ./
RUN chmod 744 start.sh sqltutor-installer.sh

COPY sqltutor.conf /usr/local/apache2/conf/
RUN echo "Include /usr/local/apache2/conf/sqltutor.conf" \
    >> /usr/local/apache2/conf/httpd.conf

# run start script
ENTRYPOINT ["/bin/bash", "/opt/start.sh"]
