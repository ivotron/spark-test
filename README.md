```bash
git clone https://github.com/noahdesu/spark-test.git
pushd spark-test
docker build -t=docker-spark-test .
docker run docker-spark-test
```


#NEW MODIFICATION:
```
USAGE: ./test.sh <docker img> <spark_env_sh_file> <spark_defaults_conf_file> nvert[ nvert[ ...]]
```
