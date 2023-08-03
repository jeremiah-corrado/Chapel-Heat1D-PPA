# Chapel Installation Instructions

There are a few ways to install Chapel on your machine to get started with this assignment. For Mac OS (and Linux) systems, Homebrew is typically the most straightforward option, especially if you already have it installed. However installing via homebrew does not support simulating multi-locale execution on your local machine which is required to fully explore the assignment. As such, using Docker or building Chapel from source are preferable for this assignment.

It is recommended that students go through the relevant Single-Locale guide first to ensure they can compile and run both example programs (`Example1.chpl` and `Example2.chpl`). Then, the Multi-Locale guides can be used to work on both portions of the assignment (`assignment1.chpl` and `assignment2.chpl`).

Also note that Chapel is supported on [ATO](https://ato.pxeger.com/run?1=m70sOSOxIDVnwYKlpSVpuhY7y4syS1Jz8jSUPFJzcvJ1FMrzi3JSFJU0rSHyUGUw5QA), which will allow you to compile and run programs in your browser. This is a convenient way to get started with Chapel without installing anything.

# Single-Locale Guides:

## [Docker](https://chapel-lang.org/install-docker.html) (any OS)

1. Make sure you have [Docker Engine](https://docs.docker.com/engine/install/) installed on your machine
2. Get the [Chapel Docker Image](https://hub.docker.com/r/chapel/chapel/):
    ```
    docker pull chapel/chapel
    ```
3. You can now use the following commands to compile and execute a Chapel program as a one-off:
    ```bash
    docker run --rm -v "$PWD":/myapp -w /myapp chapel/chapel myProgram.chpl
    docker run --rm -v "$PWD":/myapp -w /myapp chapel/chapel ./myProgram
    ```

## [From Source](https://chapel-lang.org/docs/usingchapel/QUICKSTART.html) (Mac OS / Linux)

1. Make sure you have the necessary [Prerequisites](https://chapel-lang.org/docs/usingchapel/prereqs.html#readme-prereqs) for Chapel
2. Download the latest Chapel [Release](https://github.com/chapel-lang/chapel/releases)
3. Unpack the release:
    ```bash
    tar xzf chapel-1.31.0.tar.gz
    ```
4. Open the unpacked directory:
    ```bash
    cd chapel-1.31.0
    ```
5. Set up your environment for Chapel's quickstart mode:
    ```bash
    source util/quickstart/setchplenv.bash
    ```
6. Build `chpl`:
    ```
    make
    ```
7. You can now compile and run Chapel program:
    ```bash
    chpl myProgram.chpl
    ./myProgram
    ```

## [Homebrew](https://formulae.brew.sh/formula/chapel)  (Mac OS / Linux)

Make sure you have [homebrew](https://brew.sh/) installed on your machine and run the following command to install chapel:

```bash
brew install chapel
```

Chapel should now be installed in your PATH and is ready to compile and run programs with:

```
chpl myProgram.chpl
./myProgram
```

# Multi-Locale Guides:


## Docker:

Chapel also has a [multi-locale version](https://hub.docker.com/r/chapel/chapel-gasnet/) of the Docker image described above. To download it, use:
```bash
docker pull chapel/chapel-gasnet
```

To compile a program, a similar command can be used:
```bash
docker run --rm -v "$PWD":/myapp -w /myapp chapel/chapel-gasnet myProgram.chpl
```

And to run, the following slightly modified command will be used, where the number after `-nl` indicates how many locales should be used for program execution (two in this case):
```bash
docker run --rm -v "$PWD":/myapp -w /myapp chapel/chapel-gasnet ./myProgram -nl2
```

## From Source

If you've installed Chapel from source, you can follow these instructions to configure your installation for multi-locale compilation and execution with the `gasnet` communication layer. Note that other hardware-specific communication layers are available for achieving higher performance on supported systems; however, those configurations are beyond the scope of this assignment.

1. go to your chapel home directory:
    ```bash
    cd $CHPL_HOME
    ```
2. re-configure your environment for [multi-locale execution](https://chapel-lang.org/docs/usingchapel/multilocale.html#readme-multilocale):
    ```bash
    source util/setchplenv.bash
    export CHPL_COMM=gasnet
    ```
3. re-build Chapel:
    ```bash
    make
    ```
4. Configure [gasnet](https://gasnet.lbl.gov/):
    1. To simulate multi-locale execution on a single machine (e.g., a laptop)
        ```bash
        export GASNET_SPAWNFN=L
        ```

        Note that this method is not geared towards performance as multiple locales will be running concurrently on the same hardware. Compiling and running Chapel programs in this mode is typically used for testing a program on a local machine before deploying on a cluster or supercomputer.

    2. OR to specify the target nodes on a cluster or supercomputer:
        ```bash
        export GASNET_SPAWNFN=S
        export GASNET_SSH_SERVERS="host1 host2 host3 ..."
        ```
        Depending on the system you are running on, some launcher settings may also need to be configured. See [this documentation](https://chapel-lang.org/docs/usingchapel/launcher.html) page for more.

5. Now, to compile and run programs, the following commands can be used, where the number after `-nl` specifies how many locales the program should run on (two in this case):
    ```bash
    chpl myProgram.chpl
    ./myProgram -nl2
    ```

# Other Important Notes:

## `config` variables

The source files associated with this assignment all contain some variables declared as `config const`. The `config` keyword designates that the value of the constant can be specified at execution time without any explicit command line parsing required. For example, `Example1.chpl` can be run for 50 time steps instead of the default of 100 using the following command:

```bash
./Example1 --nt=50
```

## The `--fast` flag:

By default the Chapel compiler encodes a significant amount of error-checking code into generated binaries. These checks are helpful for debugging; however can significantly hinder performance when running a computationally expensive program. As such, once you are reasonable sure that a program is running correctly on a small problem size, it is recommended that you compile with `--fast` to disable most error-checking code before running on larger problem sizes.

This might go something like:
```bash
chpl myProgram.chpl
./myProgram --someProblemSize=100
```
```bash
chpl myProgram.chpl --fast
./myProgram --someProblemSize=1e10
```
