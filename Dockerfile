# DOCKER-VERSION 0.3.4
FROM perl:5.20
## Installing cpanm to get perl SvG module
RUN curl -L http://cpanmin.us | perl - App::cpanminus
RUN cpanm SVG

#__________________________________________________________
# Installing blast
## Esta opcion descarga blast cada vez y tarda mucho.
#RUN mkdir /opt/blast && curl ftp://ftp.ncbi.nlm.nih.gov/blast/executables/blast+/2.2.30/ncbi-blast-2.2.30+-x64-linux.tar.gz | tar -zxC /opt/blast --strip-components=1
RUN if [ ! -d /opt ]; then mkdir /opt; fi

# Esta opcion no corre porque no se como pasarle el instalador de blast que ya tengo en la carpeta, talvez con volume
# RUN mv ncbi-blast-2.3.0+-x64-linux.tar.gz /opt && cd /opt | tar -zxvf ncbi-blast-2.3.0+-x64-linux.tar.gz
## 
# ENV PATH /opt/ncbi-blast-2.3.0+/bin:$PATH

#______________________
# Installing GBlocks
RUN curl -SL http://molevol.cmima.csic.es/castresana/Gblocks/Gblocks_Linux64_0.91b.tar.Z | tar -xzC /opt && ln -s /opt/Gblocks_0.91b/Gblocks /usr/bin/Gblocks

## Moving to myapp directory
COPY . /usr/src/myapp
WORKDIR /usr/src/myapp


CMD [ "perl", "./helloWorld.pl" ]
