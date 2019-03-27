# CORASON

## CORe Analysis of Syntenic Orthologs to prioritize Natural Product-Biosynthetic Gene Clusters
CORASON is a visual tool that identifies gene clusters that share a common genomic core and reconstructs multi-locus phylogenies of these gene clusters to explore their evolutionary relatioinships.

**Input:** query gene and RAST genome database.  
**Output:** SVG graph with clusters sorted according to the multi-locus phylogeny of the common core.  

CORASON was developed to find and prioritize biosynthetic gene clusters, but can be used for any kind of clusters.  

#### Advantages
-**SVG graphs** Scalable graphs that allows metadata easy display.  
-**Interactive** CORASON is not a static database, it allows you to explore your own genomes.  
-**Reproducibility** CORASON runs on docker, which allows to always perform the same analysis even if you change your Linux/perl/blast/muscle/Gblocks/quicktree distributions.  

## CORASON Installation guide

0. Install docker engine   
1. Download nselem/corason docker-image  
2. Run CORASON   

Follow the steps, and type the commands into your terminal, do not type $.  

### 0. Install docker engine
CORASON runs on docker. If you have docker engine installed, please skip this step. This is a Linux minimal docker installation guide, if you don't use Linux or you are looking for a detailed tutorial on Linux/Windows/Mac Docker engine installation please consult [Docker getting Starting] (https://docs.docker.com/linux/step_one/).  

`$ curl -fsSL https://get.docker.com/ | sh `  
*if you don’t have curl search on this document curl installation  
Then type:  
    `$ sudo usermod -aG docker your-user`

###### Important step:  
Log out from your ubuntu session (restart your machine) and get back in into your user session before the next step.
You may need to restart your computer and not just log out from your session in order to changes to take effect.

Test your docker engine with the command:  
`$ docker run hello-world`  

### 1 Download CORASON images from DockerHub
`$ docker pull nselem/corason:latest  `  

##### Important  
`docker pull ` may be slow depending on your internet connection, because the large nselem/corason docker-image is being downloaded. This only needs to happen once.

### 2 Run CORASON
#### 2.1 Set your database  
Create an empty directory that contains your [[Input Files]]:  
RAST-genome data base, Rast_Ids file and file.query  
`$ mkdir mydir`  
place your files inside the directory _mydir_ :  
![mydir.png](https://github.com/nselem/corason/blob/master/IMAGES/mydir3.png)  
GENOMES    (dir)  
RAST_IDs   (tab separated file)  
file.query (aminoacid fasta file) Save as many queries as you wish to process.  

### 2.2 Run your docker nselem/corason image  

`$ docker run --rm -i -t -v $(pwd):/usr/src/CORASON  nselem/corason /bin/bash`

**$(pwd)** points to your working directory where you store your query file and GENOMES database.  
Use absolute paths. If you do not know the path to your current working directory type on the terminal  
`$ pwd`  
**/usr/src/CORASON** is fixed at the docker images, you should always use this name.  

### 2.3 Run CORASON inside your docker  

`$ corason.pl -q yourquery.query -rast_ids yourRAST.Ids -s yourspecial_org`
once you finished all your queries exit the container  
`$ exit`  

### 2.3.1 Run CORASON image on exec mode  
You can also run corason from the beggining of the image without the interactive terminal. The next line is equivalent to steps 2.2 (Run your docker nselem/corason image) and 2.3 (2.3 Run CORASON inside your docker)  

`docker run --rm -v $(pwd):/usr/src/CORASON nselem/corason:latest /root/corason/CORASON/SSHcorason.pl yourquery.query yourRAST.Ids yourspecial_org`

### 2.4 Read your results! 
Outputs will be on the new folder /mypath/mydir/query   
- query.svg  SVG file with clusters similar to you query sorted phylogenetically  
- query_Report   Functional cluster genomic core report.
- *.tre Phylogenetic tree of the genomic cluster core.

![Results.png](https://github.com/nselem/corason/blob/master/IMAGES/yourquery2.png)  
In this example the query file was yourquery.query and the input directory was /home/mydir. Output files are located in /home/mydir/yourquery  
### Links  
The CORASON source code and docker file are located at:  
[Code] (https://github.com/nselem/corason  )  
[Docker] (https://hub.docker.com/r/nselem/corason/  )  

### curl installation
- `$ which curl`
- `$ sudo apt-get update`
- `$ sudo apt-get install curl`
### Example  
### Convert data
perl gbkIndex.pl yourgbkfolder  
