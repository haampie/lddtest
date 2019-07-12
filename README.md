This is a WIP repo that will serve as a test environment for a custom `ldd` implementation.

```
$ git clone git@github.com:haampie/lddtest.git && cd lddtest
$ docker build -t lddtest .
$ docker run -v $PWD:/development lddtest
```

## Current setup

I'm building the shared libs in the same folder as their source file.

```
$ tree src
src/
|-- a
|   |-- b
|   |   |-- c
|   |   |   `-- libc.c
|   |   `-- libb.c
|   |-- liba.c
|   `-- libd.c
`-- main.c
```

Currently there is simply a chain of dependencies as follows:

```
main <- liba <- libb <- libc <- libd
```

- The `main` executable has an `RPATH` set to `$ORIGIN/a` = `src/a`
- `liblibb.so` has a `RUNPATH` set to `$ORIGIN/b` == `src/a/b/`
- `liblibc.so` has no `RPATH` or `RUNPATH` (but it inherits the `RPATH` from `main`)
- `liblibd.so` has no `RPATH` or `RUNPATH`


## `ldd` vs `lddtree`

This setup exposes a bug in pax-utils's `lddtree`:

```
$ ldd src/main
        linux-vdso.so.1 =>  (0x00007fff111e9000)
        libliba.so => /development/src/a/libliba.so (0x00007f49449cd000)
        libc.so.6 => /lib/x86_64-linux-gnu/libc.so.6 (0x00007f4944603000)
        liblibb.so => /development/src/a/b/liblibb.so (0x00007f4944401000)
        /lib64/ld-linux-x86-64.so.2 (0x00007f4944bcf000)
        liblibc.so => /development/src/a/b/c/liblibc.so (0x00007f49441ff000)
        liblibd.so => /development/src/a/liblibd.so (0x00007f4943ffd000)

$ lddtree src/main
main => src/main (interpreter => /lib64/ld-linux-x86-64.so.2)
    libliba.so => src/a/libliba.so
        liblibb.so => src/a/b/liblibb.so
            liblibc.so => src/a/b/c/liblibc.so
                liblibd.so => not found
    libc.so.6 => /lib/x86_64-linux-gnu/libc.so.6
        ld-linux-x86-64.so.2 => /lib64/ld-linux-x86-64.so.2
```

`lddtree` tells us that `liblibd.so` is not found, but it should because it is in `main`s `RPATH`.

Maybe it's technically not a bug, since it seems `RPATH` is deprecated?
