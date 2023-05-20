# Sustainability Aspects of Software Architecture 

This is the code repository for my masters thesis _"Influence of software architecture on the sustainability of a software system"_ (Original German Title: _"Einfluss von Softwarearchitektur auf die Nachhaltigkeit eines Softwaresystems"_).
This repository contains every code artefact created during the work on the thesis.

## Setup

### PDU

The experiment uses the PDU [GUDE Expert Power Control 1202](https://gude-systems.com/produkte/expert-power-control-1202) to measure energy data from the DUT. 
The PDU must be connected to a network and have both `SNMP` and `SNMP v2` protocols enabled.

### Analysis Computer

The Analysis computer must have [Docker](https://www.docker.com/) installed and must be connected to the PDU and DUT.
The project root contains a `docker-compose.analysis.yaml` with the necessary analysis tools used for the experiment. 
It is meant to run on the analysis computer and runs a prometheus instance together with an SNMP exporter to crawl energy metrics from the used PDU. 
Prometheus is configured to retain metrics over 90 days.

It is necessary to set the IP address of the PDU manually in the compose file.
```yaml
extra_hosts:
  - "pdu.local:192.168.178.78" # Set to the PDUs IP address
```

Note that the SNMP exporter uses a custom generated configuration found in [analysis/snmp.yml](analysis/snmp.yml). 
It has been generated based on the MIBs provided by the PDU. 
To learn more about the configuration and the generation process see [SNMP Exporter](https://github.com/prometheus/snmp_exporter).

Prometheus is configured to scrape metrics from the PDU and DUT every second, the scrape config is found in [analysis/prometheus.yml](analysis/prometheus.yml). 
To complete the setup it is required to fill the IP address of the DUT in the scrape configuration.
```yaml
scrape_configs:
  - job_name: node
    static_configs:
    - targets: 
      - "192.168.178.81:9100" # Set to the DUT IP address
```
Prometheus entrypoint is overridden using a [customized script](analysis/scripts/prometheus-init.sh) which substitues environment variables in the configuration. However, it is not being used and heavily tested. 

Once everything is setup the analysis tools can be run using `docker compose -f docker-compose.analysis.yaml up`.

### DUT

The DUT must have [Docker](https://www.docker.com/) installed.
The project root contains a `docker-compose.dut.yaml` with the tools meant to run on the DUT. During the whole experiments a [Node Exporter](https://github.com/prometheus/node_exporter) is running to provide hardware metrics that will be scraped by prometheus.
Use `docker compose -f docker-compose.dut.yaml up` to run the tools.

Some experiment scripts require to have SSH access on the DUT, so make sure to setup proper SSH access from the analysis computer to the DUT.
Also some scripts perform reboots of the DUT, so it might be suitable to add apply a sudoers setting so that no password entry is required.
Edit `/etc/sudoers` and add the following lines, after that add the user to the `admin` group.
```
%admin ALL=NOPASSWD: /sbin/halt, /sbin/reboot, /sbin/poweroff
```
Also it is necessary to clone this project on the machine.
```
git clone --depth 1 git@github.com:twobiers/software-architecture-sustainability-experiment.git
```

## Experiments

The following paragraph will summarize all experiments that can be executed.
All experiments can be run with a script and output a dataset with metadata (at least timestamps) for further analysis.
**Note that all mentioned scripts must have the projects root as the PWD**.

## Base Analysis

### Scripts
| Description                                              | Script (Executing Device)                                                 | Result Dataset                                     | Required Software                                      |
| -------------------------------------------------------- | ------------------------------------------------------------------------- | -------------------------------------------------- | ------------------------------------------------------ |
| Baseline Power Usage                                     | [measure_baseline.sh](./analysis/scripts/measure_baseline.sh) (DUT)       | results/base/baseline.csv                          | -                                                      |
| Staged CPU utilization                                   | [run-cpu.sh](./analysis/scripts/dut/run-cpu.sh) (DUT)                     | results/base/cpubench/cpubench-log.csv             | [stress-ng](https://github.com/ColinIanKing/stress-ng) |
| Staged I/O utilization                                   | [run-iobench.sh](./analysis/scripts/dut/run-iobench.sh) (DUT)             | results/base/iobench/{iobench-log.csv,iobench.csv} | [fio](https://github.com/axboe/fio)                    |
| Staged Memory utilization                                | [run-membench.sh](./analysis/scripts/dut/run-membench.sh) (DUT)           | results/base/membench/membench-log.csv             | [stress-ng](https://github.com/ColinIanKing/stress-ng) |
| Staged Network utilization (localhost)                   | [run-netbench-lo.sh](./analysis/scripts/dut/run-netbench-lo.sh) (DUT)     | results/base/netbench/netbench-log.csv             | [iperf3](https://github.com/esnet/iperf)               |
| Staged Network utilization (Ethernet / Physical network) | [run-netbench.sh](./analysis/scripts/run-netbench.sh) (Analysis Computer) | results/base/netbench/netbench-log.csv             | [iperf3](https://github.com/esnet/iperf)               |


## Case Study 1: Caching in a Three-Layer-Architecture

It is required to prepare the detabase with the dataset. A convenience script is provided to perform the task.
To prepare the databse first switch into the `case-study-caching` directory and start the databse using `docker-compose up mongo -d`.
Afterwards simply run the script `./prepare-db-openfoodfacts.sh`.

To execute the experiment which will perform a round-roubin execution of different caching implementations, switch back to the root directoy and run `./case-study-caching/scripts/run-all-benchmarks.sh`. You probably need to tweak some parameters like DUT IP address and location of the cloned project directory in the `./case-study-caching/scripts/run-single-benchmark.sh` script.

The `./case-study-caching` directory also contains the implementation code of the different caching implementations. To build the required docker images [Jib](https://github.com/GoogleContainerTools/jib) is leveraged together with two custom gradle tasks `jibAll` `jibDockerBuildAll` to build all subprojects indepently. To build the required docker images locally, just run `./gradlew jibDockerBuildAll`.

## Case Study 2: Merge Microservices into a Monolithic

It is required to install [hurl](https://hurl.dev/) on the analysis computer to make the script work correctly.

To execute the experiment which will perform a round-roubin execution of the monolithic and microservice implementatio run `./case-study-dungeon/scripts/run-all-benchmarks.sh`. You probably need to tweak some parameters like DUT IP address and location of the cloned project directory in the `./case-study-dungeon/scripts/run-single-benchmark.sh` script.

The `./case-study-dungeon` directory contains three submodules (See [.gitmodules](.gitmodules)) with modified sources tweaked for the thesis. Note that this repository only just includes the artefacts that has been created indepentenly for the thesis. Code artefacts of the whole project "The Microservice Dungeon" can be found [here](https://gitlab.com/the-microservice-dungeon/).
First there's `dungeon-monolith` which is the monolithic implementation fo the project "The Microservice Dungeon". Second the `local-dev-environment` runs both the microservice and monolithic implementations in a docker environment and also the player instances, it also includes some convenience scripts. Last, there's the `player-hackschnitzel` which contains the player implementation.

## Data Analysis

The Data Analyis part is done using a [Jupyter Notebook](./results/analysis.ipynb). It requires a Jupyter Environemnt like [JupyterLab](https://jupyter.org/install) or [Visual Studio Code](https://code.visualstudio.com/) and [Python 3](https://www.python.org/) with the packages [Pandas](https://pandas.pydata.org/), [seaborn](https://seaborn.pydata.org/), [prometheus-pandas](https://pypi.org/project/prometheus-pandas/) and [SciPy](https://scipy.org/).