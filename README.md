[comment]: <> (# parallel-python-calls-scrpit)

# Table of contents
- [Table of contents](#table-of-contents)
- [Introduction <a name="introduction"></a>](#introduction-a-nameintroductiona)
- [Minimal Example <a name="minimal-example"></a>](#minimal-example-a-nameminimal-examplea)
  - [About the python script](#about-the-python-script)
  - [Launching the script](#launching-the-script)
- [Optional arguments](#optional-arguments)
- [Hard-coded parameters](#hard-coded-parameters)
- [A word of advice](#a-word-of-advice)
  - [Shutting down the script (CTRL+C)](#shutting-down-the-script-ctrlc)

# Introduction

A simple bash script to call multiple python scripts in parallel and track their progress. 

The script displays on screen the current PIDs of the launched processes and whether they have terminated.

The python scripts are launched in background and their outputs are logged in a ```.txt``` file in a logs folder.
By default, a new folder is created with the current date.
The log-file for each script call is named with timestamp (date+time; e.g. ```2022-04-14_16-17-52.txt```).

The resulting folder structure will be something like
```
.
├── logs
│   └── logs_2022-04-14
│       ├── 2022-04-14_16-17-19.txt
│       ├── 2022-04-14_16-17-20.txt
│       ├── 2022-04-14_16-17-21.txt
├── main.sh
└── script_example.py
```

This can be changed in the `main.sh` script to suit your needs.

# Minimal Example

## About the python script
The python script to call is hardcoded in the script. 
In this case the we'll call the script ```script_example.py```, which simply sleeps for the number of seconds
passed by the ```-t``` option and prints a few things on screen.

A standalone usage would be like
```shell
python script_example.py -t 10
```

I find it useful if the script that is being called prints its own PID as first thing. 
This helps to keep track of it in case it is necessary to _kill_ it (_with kindness_).

In the example, each call to the python script passes a different value of ```-t``` (11, 12, 13, ...).

You can change the script to call by adapting the code to your needs. 
The call to the python script is in lines 37-39 of ```main.sh```. 

## Launching the script

Run
```shell
./main.sh
```

Output
```text
init > [19652] @ ./logs/logs_2022-04-14/2022-04-14_16-19-36.txt | counter:1 
init > [19657] @ ./logs/logs_2022-04-14/2022-04-14_16-19-37.txt | counter:2 
init > [19662] @ ./logs/logs_2022-04-14/2022-04-14_16-19-38.txt | counter:3 
[19652] O | [19657] O | [19662] O | 3/3 running
[19652] X | [19657] O | [19662] O | 2/3 running
[19652] X | [19657] X | [19662] X | 0/3 running
3/5 done
init > [19701] @ ./logs/logs_2022-04-14/2022-04-14_16-20-09.txt | counter:4 
init > [19704] @ ./logs/logs_2022-04-14/2022-04-14_16-20-10.txt | counter:5 
[19701] O | [19704] O | 2/2 running
[19701] O | [19704] O | 2/2 running
[19701] X | [19704] X | 0/2 running
5/5 done
All done!!
```

(if this is not working, you might need to enable execution with ```chmod +x main.sh```)

# Optional arguments

The total number of instances to run defaults to 5.
However, this can be passed as the first argument to the script.
```shell
./main.sh ${1:-5}
```

For example if I want to call 12 instances of my python script, I can simply call

```shell
./main.sh 12
```

# Hard-coded parameters
Some parameters are better hard-coded than passed as optional parameters (in my opinion).
These are:
- the maximum number of processes to launch in parallel
- the time to wait in-between calls to the python script (set to at least 1 second)
- the time to wait in-between checks of the active processes 

They can be changed at the beginning of the main script.

# A word of advice

When launching scripts in parallel, be mindful of the resources available at your disposal 
and those required by your python script.

For example, if you have 8GB of RAM and each of your python scripts requires 4GB, then you clearly can't call 10 of them in parallel!
Similarly, if your CPU has 4 cores, it is better not to call more than 4 scripts at a time as they will be competing for resources.

Be also mindful of other people that may be using the same machine as you!

## Shutting down the script (CTRL+C)

Sometimes scripts don't behave as we'd like and we furiously hit the CTRL+C buttons to try to stop them.
Beacuse this script launches the python scripts in background, quitting the ```main.sh``` script will not also quit the python script.
It will instead, stop the main script from calling a new batch of scripts.

To stop the runaway job, refer to its PID and... _exterminate_ it!