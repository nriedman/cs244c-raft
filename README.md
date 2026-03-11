# CS244c Final Project

## Setup

Included is a docker preparation that makes enviornment setup more straightforwared. First, make sure to have Docker installed on your system and running. Next, in the root directory of the project, run:

```
./run_docker.sh
```
If there is an issue with permissions, grant executable permissions to the script using your preferred method or:

```
chmod +x run_docker.sh
```

Once the container is active, you can build the example application as follows:

```
go build -o raftexample ./raftexample
```
See the [original project setup](https://docs.docker.com/desktop/?_gl=1*1svchvc*_gcl_au*MjI5NjYzODg2LjE3NzMyMTg5Njk.*_ga*MTcyODEzMjM2LjE3NzMyMTg5Njk.*_ga_XJWPQMJYHQ*czE3NzMyMTg5NjkkbzEkZzEkdDE3NzMyMTg5NzMkajU2JGwwJGgw) instructions for an example of how to run a single node or a cluster.

## Network Layer

To initialize network (e.g. with 3 nodes):
```
cd network
sudo ./setup_raft_net.sh 3
```

If there is an issue with permissions for network setup, run:
```
chmod +x setup_network.sh
```

to add latency (e.g. 100ms from node 1 to node 2):
```
sudo ./setup_raft_net.sh 3 delay 1 2 100
```

## Acknowledgements

This repository is a modified version of the [example project](https://github.com/etcd-io/etcd/tree/main/contrib/raftexample) by [etcd](https://github.com/etcd-io). The following files have been modified from their original versions:

- `raft.go`
