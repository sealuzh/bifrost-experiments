# Bifrost Experimentation

## Setup
You can use the ```setup_google_cloud_engine.sh``` shell script to deploy a Docker Swarm of adjustable size. Using ```sh setup_google_cloud_engine.sh <NODES> <PROJECTID>``` the script will automatically spin up a Docker Swarm, backed by Consul as Key-Value store and using the number of nodes given as second parameter. The prior installation and configuration of the [Google Cloud SDK](https://cloud.google.com/sdk/) is necessary.

## Evaluation of End-User Overhead
Two scripts can be used to replicate the overhead evaluation of the paper, found under ```ex_1_end_user_overhead```

* ```measure_baseline.sh``` conducts 5 runs of the sample application under a steady traffic of 35 requests per second. 
* ```measure_bifrost.sh``` conducts 5 runs of the sample application including the Bifrost middleware without running any release strategy, and 5 runs including the Bifrost middleware running the described sample strategy.

## Evaluation of Engine Performance

### Executing multiple release strategies
The scripts to replicate the setup of executing multiple release strategies can be found under ```ex_2_multiple_release_strategies```

* ```setup.sh``` setup of all necessary containers
* ```run.sh <NUMBER_OF_PARALLEL_STRATEGIES>``` launches a run using the specified amounts of parallel strategies.

### Executing release strategies with many checks
The scripts to replicate the setup of executing release strategies with many checks can be found under ```ex_3_complex_release_strategies```

* ```run.sh <STRATEGY_COMPLEXITY>``` launches a run using the specified amounts of parallel strategies.

As the strategies are pre-baked into the bifrostuzh/cli container-image, only the following numbers are possible: 1, 5, 10, 20, 30, 40 ... up until 200 in steps of 10. 