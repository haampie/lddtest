This is a WIP repo that will serve as a test environment for a custom `ldd` implementation.

```
$ git clone git@github.com:haampie/lddtest.git && cd lddtest
$ docker build -t lddtest .
$ docker run -v $PWD:/development lddtest
```
