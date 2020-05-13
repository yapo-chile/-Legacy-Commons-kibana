# kibana
Custom implementation of kibana for elasticsearch


## Requirements 

- Docker
- [optional] TravisCI  (Please check .travis.yml file) 

## How to run kibana

* Create the dir: `~/go/src/github.mpi-internal.com/Yapo`


* Clone this repo:

  ```
  $ cd ~/go/src/github.mpi-internal.com/Yapo
  $ git clone git@github.mpi-internal.com:Yapo/kibana.git
  ```

* On the top dir execute the make instruction to clean and start:

  ```
  $ cd kibana
  $ make docker-build
  $ docker run {docker-tag}
  ```

* To modify env/config vars:

  ```
  $ vim kibana/scripts/commands/vars.sh
  ```

