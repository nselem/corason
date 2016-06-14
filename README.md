# EvoDivMet
Bioinformatic Tools for studying evolution of metabolic diversity

## CORASON
### CORe Analysis of Syntenic Orthologs for priorize Natural Product-Biosynthetic Gene Cluster
CORASON searchs for gene clusters   
Input: query gen and RAST genome database.  
Output: SVG graph with clusters sorted according to core genomic tree from clusters.  

CORASON was developed to find biosynthetic gene clusters, but it can used for any kind of clusters.

####Advantages
SVG
Docker Reproducibility.  

## Installation guide
### 0. Install docker engine
(If you have docker engine skip this step)  
`$ curl -fsSL https://get.docker.com/ | sh `  
*if you don’t have curl search on this document curl installation  

*This step may be before hello-world  
     `sudo usermod -aG docker your-user`

###### Important step:  
Log out from your ubuntu session (restart the machine)  and get back in into your user session before the next step
May be important to restart your computer, not just log out yor session, or maybe importatn to waite some minutes, not sure until more proof performed.

Test your docker engine with:  
`$ docker run hello-world`  

This are Linux minimal docker installation guide, for a detailed tutorial Linux/Windows/Mac installation Docker engine please consult [Docker getting Starting] (https://docs.docker.com/linux/step_one/).

### 1 Set your database  
Create an empty directory that contains your RAST-genome data base, your Rast_Ids file and your query.
`$ mkdir mydir`
place inside my dir your files:  
GENOMES    (dir)
RAST_IDs   (tab separated file)
file.query (aminoacid fasta file)  Save as many queries as you wish to process.

### 2. Run your docker nselem/evodivmet image  

`$ docker run -i -t -v /mypath/mydir:/usr/src/CORASON  nselem/evodivmet /bin/bash`

/mypath/mydir/ is your local directory were you store your inputs, can have any name you give.  
Use absolute path to your dir, if you don’t know the path you can place yorself on you directory and ask on the terminal 
`$ pwd`
/usr/src/CORASON is fixed at the docker images, you should always use this name.  

#####Important  
First time you perform `docker run ` will be very slow because docker image is being downloaded, its only first time won’t happen again.

### 3. Run CORASON inside your docker  

`corason.pl -q 1308.query -rast_ids RAST.IDs -s 326020`

### 4. Read your results !  
query.svg query_Report *.tre will be on /mypath/mydir/  

### Links  
Code and docker file located at:
https://github.com/nselem/EvoDivMet

### curl installation
- `$ which curl`
- `$ sudo apt-get update`
-  `$ sudo apt-get install curl`

### To do list
- [x] Redirect process to a different folder so multiple runs can be performed without data mess
- [ ] Write the tutorial
- [ ] Write a myRast Docker file
- [ ] Learn Docker-Apache to link with Evomining
- [ ] Test with many users
