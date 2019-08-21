# DOCKER-VERSION 0.3.4
FROM bioperl/bioperl

## Installing perl module
RUN curl -L http://cpanmin.us | perl - App::cpanminus
RUN cpanm SVG
RUN cpanm Bio::SeqIO;
RUN cpanm Bio::SeqFeature::Generic;
#RUN cpanm Bio::Seq;
RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y wget

###____________________________________________
RUN if [ ! -d /opt ]; then mkdir /opt; fi
###____________________________________________
# Installing blast
RUN mkdir /opt/blast && curl ftp://ftp.ncbi.nlm.nih.gov/blast/executables/blast+/2.2.30/ncbi-blast-2.2.30+-x64-linux.tar.gz | tar -zxC /opt/blast --strip-components=1
######_____________________________________________________________________________________
# Instaling muscle
 RUN wget -O /opt/muscle3.8.tar.gz http://www.drive5.com/muscle/downloads3.8.31/muscle3.8.31_i86linux64.tar.gz
 RUN mkdir /opt/muscle && tar -C /opt/muscle -xzvf /opt/muscle3.8.tar.gz && ln -s /opt/muscle/muscle3.8.31_i86linux64 /opt/muscle/muscle  
####___________________________________________________________________
## Instaling FastTree
RUN mkdir /opt/fasttree && wget -O /opt/fasttree/FastTree http://www.microbesonline.org/fasttree/FastTree && chmod +x /opt/fasttree/FastTree
#________________________________________________________________________________
# Installing NewickTools
RUN wget -O /opt/newick-utils-1.6.tar.gz http://cegg.unige.ch/pub/newick-utils-1.6-Linux-x86_64-disabled-extra.tar.gz 
RUN mkdir /opt/nw && tar -C /opt/nw -xzvf /opt/newick-utils-1.6.tar.gz && cd /opt/nw/newick-utils-1.6 && cp src/nw_* /usr/local/bin
##___________________________________________________
#### Vim
RUN cd ~
RUN apt-get install -y git-all
RUN apt-get install -y libncurses5-dev libncursesw5-dev
#RUN apt-get build-dep vim
RUN git clone https://github.com/vim/vim.git
RUN cd vim && ./configure && make VIMRUNTIMEDIR=/usr/share/vim/vim74 && make install
#_________________________________________________________________________________________________
## CORASON
RUN cd /opt && git clone https://github.com/nselem/corason.git
####__________________________________________________________________
# Installing GBlocks
RUN tar -xf /opt/corason/CORASON/Gblocks_Linux64_0.91b.tar.Z -C /opt/ && ln -s /opt/Gblocks_0.91b/Gblocks /usr/bin/Gblocks
## Other perl modules
RUN locale-gen en_US.utf8

######### PATHS ENVIRONMENT
ENV PATH /opt/blast/bin:$PATH:/opt/muscle:/opt/Gblocks:/opt/quicktree/quicktree_1.1/bin:/opt/corason/CORASON:/opt/fasttree
#RUN mv /corason  /opt/.
RUN chmod +x /opt/corason/CORASON/*pl  
## Moving to myapp directory
RUN mkdir /home/output
WORKDIR /home/output 
## Como paso variables ?
CMD ["perl", "/opt/corason/CORASON/corason.pl"]
## Volumen para escribir la salida
