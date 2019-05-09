Running Your First Job on GRACE
==============================

Logging In
----------
```bash
ssh <username>@login.hpc.uams.edu
```

If this is your first time logging into the system, now is when you should remember to change your password.

```bash
passwd
```


```bash
showstate
```


Submit a Simple Job
------------
```bash
echo lscpu | qsub
```

```bash
less STDIN.o########
```

Submit a Scripted Job
---------------------
```bash
nano cpuinfo.script
```

```bash
#!/bin/bash
#PBS -k o
#PBS -M <YOUR_EMAIL>@uams.edu
#PBS -m abe
#PHS -N CPUinfo
#PBS -j oe

lscpu
```

```bash
qsub cpuinfo.script
```

```bash
qsub -l feature=xeon cpuinfo.script
```

Monitoring Jobs
---------------
```bash
showstate
```

```bash
qstat
```

```bash
qstat -f
```

Installing Software
-------------------
```bash
module avail
```

```bash
module spider <search>
```

```bash
module load <module_name>
```

EasyBuild

Submit a Multistage Job
-----------------------
This git repository serves as an example of many of the steps involved in submitting a more complex job. To begin clone this git repository into your home directory on the HPC.
```bash
git clone https://github.com/utecht/hpc_tut
cd hpc_tut
```
To find a non-trivial amount of work to do, this example will follow the [Moving Pictures tutorial](https://docs.qiime2.org/2019.4/tutorials/moving-pictures/) of the QIIME2 microbiome toolset. This will require installing and setting up the QIIME tool on the HPC. To accomplish this we will use EasyBuild and a set of EasyBuild scripts found on their online repository. https://github.com/easybuilders/easybuild-easyconfigs
```bash
cd dependencies
module load EasyBuild
eb Miniconda3-4.4.10.eb
eb QIIME2-2019.1.eb
cd ..
```
Now on the login node we can ensure that the QIIME2 tool has installed properly.  If loading the module fails, read the output from module for advice on how to proceed.
```bash
module avail
module load QIIME2
qiime --version
```
Next we need to download the sample data for the tutorial and edit the step scripts to have your email and home path. This is all done with the initialize.sh script, which can serve as a reference for downloading data from the internet or mass find and replace of files.
```bash
./initialize.sh
```

Now that the data is in place and the module has been installed it is time to submit the actual work to the job queue and wait for the emails to roll in. The Moving Pictures tutorial has roughly 20 QIIME commands to run which produce various outputs.  Some of these commands are quite intense and others will rely on their output before they can run. On the HPC there is a set cost to spinning up a job on a node and so often you will want to chain many commands together rather than submitting a job for each command that needs to be run.  For the Moving Pictures tutorial I have broken the 20 commands into 3 sections, an initial very CPU heavy import/demultiplex/align and then 2 low CPU jobs in which smaller calculations are performed with the output from the first job.  Looking at the top of the import.script with the head command you can see that it requests 1 node with 36 ppn, while the other two scripts just take the queue default of a single CPU.
 ```bash
 cd steps
 head -n20 import.script
 ```
 
 Each of these scripts could be queued just by running the qsub command, however the second two scripts cannot run until the first job has finished, the qsub command takes a `depend=afterok:<jobid>` argument, which will submit those jobs onto the queue with a hold until the first has successfully exited. The run_all.sh script shows how to schedule multiple jobs at a time while capturing their job_id to feed into later required jobs.
 ```bash
 cat run_all.sh
 ./run_all.sh
 ```
 
 Now you can sit back and wait for the emails to come pouring in.  The first step takes roughly 10 minutes to complete and the later ones about half as long each, although they will run at the same time. Use the commands from the "Monitoring Jobs" section above to watch their progress.

Once all of the jobs have finished it is time to pack up your results and scp them back to your local machine to analyse the various visualizations and result tables.
```bash
cd ..
tar cfz results.tar.gz results/
exit
scp <username>@login.hpc.uams.edu:hpc_tut/results.tar.gz .
tar xfz results.tar.gz
```
