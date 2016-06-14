# DOCKER-VERSION 0.3.4
FROM perl:5.20

## Installing perl module
RUN curl -L http://cpanmin.us | perl - App::cpanminus
RUN cpanm SVG

###____________________________________________

RUN if [ ! -d /opt ]; then mkdir /opt; fi
###__________________________________________________________________________________________________________________________________
# Installing blast

RUN mkdir /opt/blast && curl ftp://ftp.ncbi.nlm.nih.gov/blast/executables/blast+/2.2.30/ncbi-blast-2.2.30+-x64-linux.tar.gz | tar -zxC /opt/blast --strip-components=1

######___________________________________________________________________________________________________________________________________
# Instaling muscle
 RUN wget -O /opt/muscle3.8.tar.gz http://www.drive5.com/muscle/downloads3.8.31/muscle3.8.31_i86linux64.tar.gz
 RUN mkdir /opt/muscle && tar -C /opt/muscle -xzvf /opt/muscle3.8.tar.gz && ln -s /opt/muscle/muscle3.8.31_i86linux64 /opt/muscle/muscle  
####___________________________________________________________________________________________________________________________________
# Installing GBlocks
RUN curl -SL http://molevol.cmima.csic.es/castresana/Gblocks/Gblocks_Linux64_0.91b.tar.Z | tar -xzC /opt && ln -s /opt/Gblocks_0.91b/Gblocks /usr/bin/Gblocks
####___________________________________________________________________________________________________________________________________
## Instaling Quicktree
RUN wget -O /opt/quicktree.tar.gz ftp://ftp.sanger.ac.uk/pub/resources/software/quicktree/quicktree.tar.gz 
RUN mkdir /opt/quicktree && tar -C /opt/quicktree -zxvf /opt/quicktree.tar.gz && cd /opt/quicktree/quicktree_1.1 &&  make quicktree
#___________________________________________________________________________________________________________________________________

# Installing NewickTools
RUN wget -O /opt/newick-utils-1.6.tar.gz http://cegg.unige.ch/pub/newick-utils-1.6-Linux-x86_64-disabled-extra.tar.gz 
RUN mkdir /opt/nw && tar -C /opt/nw -xzvf /opt/newick-utils-1.6.tar.gz && cd /opt/nw/newick-utils-1.6 && cp src/nw_* /usr/local/bin

##___________________________________________________

#### Vim
RUN cd ~
RUN git clone https://github.com/vim/vim.git
RUN cd vim && ./configure && make VIMRUNTIMEDIR=/usr/share/vim/vim74 && make install

#_________________________________________________________________________________________________
## CORASON
RUN git clone https://github.com/nselem/EvoDivMet
RUN mkdir /opt/CORASON

 ######### PATHS ENVIRONMENT
ENV PATH /opt/blast/bin:$PATH:/opt/muscle:/opt/Gblocks:/opt/quicktree/quicktree_1.1/bin:/root/EvoDivMet/CORASON
## Moving to myapp directory
RUN mkdir /usr/src/CORASON
### Aqui puedo pasar GENOMES, query, RAST_IDs
COPY . /usr/src/CORASON

WORKDIR /usr/src/CORASON 
## Como paso variables ?
CMD [ "perl", "./testworld.pl" ]

## Volumen para escribir la salida
