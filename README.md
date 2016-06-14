# EvoDivMet
Bioinformatic Tools for study Evolution of metabolic diversity

### CORASON
## CORe Analysis of Syntenic Orthologs for priorize Natural Product-Biosynthetic Gene Cluster
CORASON searchs for gene clusters 
Input: query gen and RAST genome database.
Output: SVG graph with clusters sorted according to core genomic tree from clusters.

CORASON was developed to find biosynthetic gene clusters, but it can used for any kind of clusters.

#Advantages
SVG
Docker Reproducibility.  

## Installation guide
# 0. Install docker engine
(If you have docker engine skip this step)
$ curl -fsSL https://get.docker.com/ | sh   
*if you don’t have curl search on this document curl installation

quizas este paso va antes
     sudo usermod -aG docker your-user

Important step!: log out from your ubuntu session (restart the machine)  and get back in into your user session before the next step

parece que es importante reiniciar la compu, no ssolo salir de la sesion

$ docker run hello-world
https://docs.docker.com/linux/step_one/

*If you would like to use Docker as a non-root user, you should now consider
adding your user to the "docker" group with something like:



Set your database
Create an empty directory that contains your genome data base, your Rast_Ids file and your query.
$ mkdir mydir
place inside my dir your files:
GENOMES
RAST_IDs
file.query

Run your docker nselem/evodivmet image




$ docker run -i -t -v /mypath/mydir:/usr/src/CORASON  nselem/evodivmet /bin/bash

%%% aqui hay que dejar claro que el path despues de los dos puntos es fijo y el otro es el que hay que cambiar

Use absolute path your dir, if you don’t know the path you can place yorself on you directory and ask on the terminal ($ pwd)
First time may be slow while docker image is downloaded, won’t happen again.

2. Run CORASON inside your docker

CORASON.pl -q 1308.query -rast_ids RAST.IDs -s 326020

3. Read your results !
query.svg query_Report *.tre will magically be on mydir

Extra

Code and docker file located at:
https://github.com/nselem/EvoDivMet

curl installation
$ which curl
$ sudo apt-get update
$ sudo apt-get install curl


