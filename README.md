# EvoDivMet
Bioinformatic Tools for studying evolution of metabolic diversity
Tools:  
- EvoMining  
- CORASON  

## CORASON

### CORe Analysis of Syntenic Orthologs to prioritize Natural Product-Biosynthetic Gene Cluster
CORASON is a visual tool that searchs for gene clusters similar to a given one, if exists a genomic core on this clusters CORASON finds it and sort them phylogenetically according to its core.  

**Input:** query gen and RAST genome database.  
**Output:** SVG graph with clusters sorted according to core genomic tree from clusters.  

CORASON was developed to find and prioritize biosynthetic gene clusters, but can be used for any kind of clusters.  

#### Advantages
-**SVG graphs** Scalable graphs that allows metadata easy display.  
-**Interactive** CORASON is not an static database, it allows you to explore your own genomes.  
-**Reproducibility** CORASON runs on docker, that allows to always conduce the same analysis even if you change your Linux/perl/blast/muscle/Gblocks/quicktree distributions.  

## CORASON Installation guide

0. Install docker engine   
1. Download nselem/evodivmet docker-image  
2. Run CORASON  

Follow the steps, and type the commands into your terminal, do not type $.  

### 1. Install docker engine
CORASON runs on docker, if you have docker engine installed skip this step. This are Linux minimal docker installation guide, if you don't use Linux or you look for a detailed tutorial on Linux/Windows/Mac Docker engine installation please consult [Docker getting Starting] (https://docs.docker.com/linux/step_one/).  

`$ curl -fsSL https://get.docker.com/ | sh `  
*if you don’t have curl search on this document curl installation  
Then type:  
    `$ sudo usermod -aG docker your-user`

###### Important step:  
Log out from your ubuntu session (restart your machine) and get back in into your user session before the next step.
You may need to restart your computer and not just log out from your session in order to changes to take effect.

Test your docker engine with the command:  
`$ docker run hello-world`  

###1 Download CORASON images from DockerHub
`$ docker pull nselem/evodivmet:latest  `  

#####Important  
`docker pull ` may be slow depending on your internet connection, because nselem/evodivmet docker-image is being downloaded, its only this time won’t happen again.

### 2 Run CORASON
#### 2.1 Set your database  
Create an empty directory that contains your [[Input Files]]: RAST-genome data base, Rast_Ids file and file.query  
`$ mkdir mydir`  
place inside my dir your files:  
![mydir.png](https://github.com/nselem/EvoDivMet/blob/master/IMAGES/mydir3.png)  
GENOMES    (dir)  
RAST_IDs   (tab separated file)  
file.query (aminoacid fasta file) Save as many queries as you wish to process.  

### 2.2 Run your docker nselem/evodivmet image  

`$ docker run -i -t -v /mypath/mydir:/usr/src/CORASON  nselem/evodivmet /bin/bash`

**/mypath/mydir/** is your local directory were you store your inputs, can have any name you choose.  
Use absolute paths, if you don’t know the path to your dir, place yourself on your directory and type on the terminal  
`$ pwd`  
**/usr/src/CORASON** is fixed at the docker images, you should always use this name.  

### 2.3 Run CORASON inside your docker  

`$ corason.pl -q yourquery.query -rast_ids yourRAST.Ids -s yourspecial_org`
once you finished all your queries exit the container  
`$ exit`  

### 2.3.1 Run CORASON image on exec mode  
You can also run corason from the beggining of the image without the interactive terminal. The next line is equivalent to steps 2.2 (Run your docker nselem/evodivmet image) and 2.3 (2.3 Run CORASON inside your docker)  

`docker run -it -v /mypath/mydir/:/usr/src/CORASON nselem/evodivmet:latest /root/EvoDivMet/CORASON/SSHcorason.pl yourquery.query yourRAST.Ids yourspecial_org`

### 2.4 Read your results ! 
Outputs will be on the new folder /mypath/mydir/query   
- query.svg  SVG file with clusters similar to you query sorted phylogenetically  
- query_Report   Functional cluster genomic core report.
- *.tre Phylogenetic tree of the genomic cluster core.

![Results.png](https://github.com/nselem/EvoDivMet/blob/master/IMAGES/yourquery2.png)  
On this example query file was yourquery.query and input directory was /home/mydir, output files are located on /home/mydir/yourquery  
### Links  
Code and docker file located at:  
[Code] (https://github.com/nselem/EvoDivMet  )  
[Docker] (https://hub.docker.com/r/nselem/evodivmet/  )  

### curl installation
- `$ which curl`
- `$ sudo apt-get update`
- `$ sudo apt-get install curl`

### To do list
- [ ] Create a direct access with Logo
- [x] Redirect process to a different folder so multiple runs can be performed without data mess
- [1/2] Write the tutorial
- [ ] Write a myRast Docker file
- [ ] Learn Docker-Apache to link with Evomining
- [ ] Test with many users
