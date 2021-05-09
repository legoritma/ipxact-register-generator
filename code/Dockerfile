FROM perl:5.14

RUN cpanm Carton
RUN mkdir -p /usr/src/data
RUN mkdir -p /usr/src/app
WORKDIR /usr/src/app

COPY cpanfile /usr/src/app
COPY Register.pm /usr/src/app
COPY main.pl /usr/src/app
COPY ipxact_template.tt /usr/src/app
RUN carton install

CMD find /usr/src/data/ -type f \( -iname \*.xlsx -o -iname \*.xls \) \
    -exec printf "\n----Processing {} ------\n" \;\
    -exec perl main.pl --input "{}" --output "{}.xml" \;