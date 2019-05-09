Running Your First Job on GRACE
==============================

Logging In
----------
```bash
ssh <username>@login.hpc.uams.edu
```

If this is your first time logging into the system, now is when you should change your password.

```bash
passwd
```

You are now on the HPC login node. From here you can stage your data and jobs to be submitted to the computational nodes in the cluster. You can view the current load of the overall system from the login node with the `showstate` command.

Submit a Simple Job
------------
While the login node is a relatively powerful server, it should not be used to do any actual work, as that could impede others ability to use the system. We use [Torque](http://docs.adaptivecomputing.com/torque/6-1-2/adminGuide/torque.htm) to manage jobs and resources on the cluster. The `qsub` program will be your primary interface for submitting jobs to the cluster. In its simplest form you can feed it a command on standard input and it will schedule and run a job. Here we will schedule a single command `lscpu` to run using all of the defaults.
```bash
echo lscpu | qsub
```
The output from jobs will end up in your home directory as they run. Since we didn't name the job we just submitted you will find a file called STDIN.o##JOBID##, which will contain the standard output of the lscpu command once it has finished running on the node it was assigned.
```bash
less STDIN.o########
```

Submit a Scripted Job
---------------------
The `qsub` program takes [many arguments](http://docs.adaptivecomputing.com/torque/6-1-2/adminGuide/torque.htm#topics/torque/commands/qsub.htm) to control where the job will be scheduled and can be fed a script of commands and arguments to be run instead of just feeding them in through a pipe. We will now create a script which will both contain the arguments and actual commands to be run.
```bash
nano cpuinfo.script
```

Below you see a simple script which will also perform the `lscpu` command as above, except this will also set a few options.
```bash
#!/bin/bash
#PBS -k o                              #<---- Only keep the standard out
#PBS -M <YOUR_EMAIL>@uams.edu.         #<---- Email address to notify
#PBS -m abe                            #<---- Status to notify the email (abort,begin,end)
#PHS -N CPUinfo                        #<---- Name of this job
#PBS -j oe                             #<---- Join both the standard out and standard error streams
                                       #<---- Commands below this point will be run on the assigned node
echo "Hello HPC"
lscpu
echo "Goodbye HPC"
```

Once this script is created it can be run by passing it to the `qsub` program. After this job has finished there will now be a file named cpuinfo.o###### in your home directory which will contain the output.
```bash
qsub cpuinfo.script
```
When submitting a script you can also pass arguments on the command line to `qsub`. Here we submit the `lscpu` script again, except this time we ask for a node with a xeon processor.  Compare the outputs of the two jobs, or experiment with different features that can be requested. 
```bash
qsub -l feature=xeon cpuinfo.script
```

Monitoring Jobs
---------------
Jobs so far have been quick to run, often though you will want to monitor longer running jobs.  Remember that the `showstate` program will display the state of the entire cluster. There are many other programs which can help you monitor your own state and jobs.

```bash
qstat
```
This program will display your current and recent jobs submitted to the cluster. The `S` column contains the current status of your jobs.
```bash
qstat -f
```
This option will print the full status of current jobs and is useful for finding the `exec_host` of a running job. Knowing the host will allow you to peek in a few ways at what the node is currently doing.

```bash
pbsnodes <nodename>
```
This shows the configuration of an individual node, as well as its current status.

With the node name we can use the Parallel Shell program `pdsh` to execute commands directly on a node. This should only ever be used to run short non-intensive commands, as it will take CPU time from any jobs that are executing on that node. Here are some possibly useful commands.
```bash
pdsh -w <nodename> free -h
pdsh -w <nodename> uptime
pdsh -w <nodename> top -b -n1
```

Installing Software
-------------------
The HPC has some software packages already installed, however they will need to be activated using [Lmod](http://lmod.readthedocs.org). You can browse avaliable modules or search for them and see descriptions with these commands.
```bash
module avail
module spider <search>
```
If one of them is already available you simply need to load it. Do note however, that this is only changing your local environment variables. If you plan on making use of anything inside of a module during a job, you must use `module load` in the job script, before you try and use the commands that it enables.
```bash
module load <module_name>
```
One of the most useful modules is [EasyBuild](https://easybuild.readthedocs.io/en/latest/). This is a build and installation framework designed for HPCs. Many scientific toolsets can be installed using it, once they are, they can be activated using the module commands above. However, EasyBuild will always have to be loaded first, before anything installed with it can be loaded, the `module spider <search>` command will explain this if you forget.
```bash
module load EasyBuild
wget https://raw.githubusercontent.com/easybuilders/easybuild-easyconfigs/master/easybuild/easyconfigs/m/Miniconda3/Miniconda3-4.5.12.eb
eb Miniconda3-4.5.12.eb
module avail
module load Miniconda3
conda --version
```

Submit a Multistage Job
-----------------------
This git repository serves as an example of many of the steps involved in submitting a more complex job. To begin, clone this git repository into your home directory on the HPC.
```bash
git clone https://github.com/utecht/hpc_tut
cd hpc_tut
```
To find a non-trivial amount of work to do, this example will follow the [Moving Pictures tutorial](https://docs.qiime2.org/2019.4/tutorials/moving-pictures/) of the QIIME2 microbiome toolset. This will require installing and setting up the QIIME2 tool on the HPC. To accomplish this we will use EasyBuild and a set of EasyBuild scripts found on their online repository. https://github.com/easybuilders/easybuild-easyconfigs
```bash
cd dependencies
module load EasyBuild
eb Miniconda3-4.4.10.eb
eb QIIME2-2019.1.eb
cd ..
```
Now, while on the login node, we can ensure that the QIIME2 tool has installed properly.  If loading the module fails, read the output from `module` for advice on how to proceed.
```bash
module avail
module load QIIME2
qiime --version
```
Next we need to download the sample data for the tutorial and edit the step scripts to have your email and home path. This is all done with the initialize.sh script, which can serve as a reference for downloading data from the internet or mass find and replace of files.
```bash
./initialize.sh
```

Now that the data is in place and the module has been installed it is time to submit the actual work to the job queue and wait for the emails to roll in. The Moving Pictures tutorial has roughly 20 QIIME2 commands to run which produce various outputs.  Some of these commands are quite intense and others will rely on previous output before they can run. On the HPC there is a set cost to spinning up a job on a node. Therefore often you will want to chain many commands together rather than submitting a job for each command that needs to be run.  For the Moving Pictures tutorial I have broken the 20 commands into 3 sections, an initial very CPU heavy import/demultiplex/align and then 2 low CPU jobs in which smaller calculations are performed with the output from the first job.  Looking at the top of the import.script with the `head` command you can see that it requests 1 node with 36 cpus, while the other two scripts just take the queue default of a single CPU.
 ```bash
 cd steps
 head -n20 import.script
 ```
 
 Each of these scripts could be queued just by running the qsub command. However the second two scripts cannot run until the first job has finished. The `qsub` command takes a `depend=afterok:<jobid>` argument, which will submit those jobs onto the queue with a hold until the first has successfully exited. The run_all.sh script shows how to schedule multiple jobs at a time while capturing their job_id to feed into later required jobs.
 ```bash
 cat run_all.sh
 ./run_all.sh
 ```
 
 Now you can sit back and wait for the emails to come pouring in.  The first step takes roughly 10 minutes to complete and the later ones about half as long each, although they will run at the same time. Use the commands from the "Monitoring Jobs" section above to watch their progress.

Once all of the jobs have finished it is time to pack up your results and scp them back to your local machine to analyze the various visualizations and result tables.
```bash
cd ..
tar cfz results.tar.gz results/
exit
scp <username>@login.hpc.uams.edu:hpc_tut/results.tar.gz .
tar xfz results.tar.gz
```
