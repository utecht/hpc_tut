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
```bash
git clone https://github.com/utecht/hpc_tut
cd hpc_tut
```

```bash
cd dependencies
module load EasyBuild
eb Miniconda3-4.4.10.eb
eb QIIME2-2019.1.eb
cd ..
```

```bash
./download_all.sh
```

 ```bash
 cd steps
 ```
 
 ```bash
 ./run_all.sh
 ```
