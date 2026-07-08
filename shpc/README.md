# README

We are using [shpc](https://singularity-hpc.readthedocs.io/en/latest/#) to install modules, we have a copy of
the singularity-hpc repo stored in `/camber/home/tools/shpc/singularity-hpc`. You must be `spack` user to get
access.

## Setup

To get started, first navigate to this directory by running

```console
cd /camber/home/tools/shpc/singularity-hpc
```

Now activate the virtual environment it should be present in `.pyenv`

```console
[spack@login singularity-hpc]$ source .pyenv/bin/activate
(.pyenv) [spack@login singularity-hpc]$
```

You should see `shpc` pre-installed in this environment

```console
(.pyenv) [spack@login singularity-hpc]$ which shpc
/camber/home/tools/shpc/singularity-hpc/.pyenv/bin/shpc
```

## Using shpc

To see a list of containers that are installed you can run `shpc list`

```console
(.pyenv) [spack@login singularity-hpc]$ shpc list
                        python:3.9
quay.io/biocontainers/vcftools:0.1.17--pl5321h077b44d_0
  quay.io/biocontainers/spades:4.2.0--h8d6e82b_1
  quay.io/biocontainers/prokka:1.14.6--pl5321hdfd78af_5
quay.io/biocontainers/biobb_amber:5.1.0--pyhdfd78af_0
quay.io/biocontainers/bedtools:2.31.1--h13024bc_3
quay.io/biocontainers/bcftools:1.22--h3a4d415_1
 quay.io/biocontainers/bowtie2:2.5.4--he96a11b_6
  quay.io/biocontainers/fastqc:0.12.1--hdfd78af_0
quay.io/biocontainers/samtools:1.22.1--h96c455f_0
     quay.io/biocontainers/bwa:0.7.19--h577a1d6_1
    quay.io/biocontainers/star:2.7.11b--h5ca1c30_6
quay.io/biocontainers/trimmomatic:0.39--hdfd78af_2
quay.io/biocontainers/freebayes:1.3.10--hbefcdb2_0
   quay.io/biocontainers/blast:2.16.0--h66d330f_5
   quay.io/biocontainers/quast:5.3.0--py313pl5321h5ca1c30_2
quay.io/biocontainers/portcullis:1.2.4--py39hc12ff1f_3
  quay.io/biocontainers/picard:3.4.0--hdfd78af_0
quay.io/biocontainers/slow5tools:1.3.0--hee927d3_1
  quay.io/biocontainers/hisat2:2.2.1--h503566f_8
   quay.io/biocontainers/gatk4:4.6.2.0--py310hdfd78af_0
```

To see any container you can use the `shpc show` command, you can use `--filter` option to filter output which
is useful. Let's say we want to find `samtools`, you can run the following

```console
(.pyenv) [spack@login singularity-hpc]$ shpc show --filter samtools
ghcr.io/autamus/samtools
quay.io/biocontainers/bioconductor-rsamtools
quay.io/biocontainers/msamtools
quay.io/biocontainers/perl-bio-samtools
quay.io/biocontainers/samtools
```

Let's try seeing the container **quay.io/biocontainers/samtools**, we can run `shpc show quay.io/biocontainers/samtools` 
and this will show metadata associated with the container including list of avaliable tags and aliases
for each program that are set in the container. 

```console
(.pyenv) [spack@login singularity-hpc]$ shpc show quay.io/biocontainers/samtools
url: https://biocontainers.pro/tools/samtools
maintainer: '@vsoch'
description: shpc-registry automated BioContainers addition for samtools
latest:
  1.22.1--h96c455f_0:
    sha256:23dc2c29f457a448a0d341fb97b2632a2c8004925214cb6420562a5b12adf8a2
tags:
  1.10--h2e538c0_3:
    sha256:84a8d0c0acec87448a47cefa60c4f4a545887239fcd7984a58b48e7a6ac86390
  1.11--h6270b1f_0:
    sha256:141120f19f849b79e05ae2fac981383988445c373b8b5db7f3dd221179af382b
  1.12--h9aed4be_1:
    sha256:5fd5f0937adf8a24b5bf7655110e501df78ae51588547c8617f17c3291a723e1
  1.13--h8c37831_0:
    sha256:04da5297386dfae2458a93613a8c60216d158ee7cb9f96188dad71c1952f7f72
  1.14--hb421002_0:
    sha256:88632c41eba8b94b7a2a1013f422aecf478a0cb278740bcc3a38058c903d61ad
  1.15--h3843a85_0:
    sha256:d68e1b5f504dc60eb9f2a02eecbac44a63f144e7d455b3fb1a25323c667ca4c4
  1.19.2--h50ea8bc_1:
    sha256:9cd15e719101ae8808e4c3f152cca2bf06f9e1ad8551ed43c1e626cb6afdaa02
  1.18--h50ea8bc_1:
    sha256:d98e76a31fc42336a11ee2b7f15a2f7dff7a36bcfd82bd712570411468573ebd
  1.17--hd87286a_2:
    sha256:b3b53a23804f421ee67d624af55c3a22cd2a8ff896d39ad38413c63488a286e4
  1.16.1--h00cdaf9_2:
    sha256:85f48a5a15fa523ba0edf3797f9e127f56e1ee4ef1d6dc90a757a53498a27c3e
  1.15.1--h6899075_1:
    sha256:7b9def45ac8a25153935ca53118c8dbed2ea92a99001c83508fec3f0f6f26802
  1.20--h50ea8bc_0:
    sha256:d0ebd10e887e3ddd02d071f1ca7b649dc90dc6fb99a5ffd0f5ebf8611a1f92cc
  1.20--h50ea8bc_1:
    sha256:bf80e07e650becfd084db1abde0fe932b50f990a07fa56421ea647b552b5a406
  1.21--h50ea8bc_0:
    sha256:783c6646029a306ec5e4162009dc1a20d8f6c528f7c380e5b4affbf12d9112e5
  1.21--h96c455f_1:
    sha256:d1585753f42f3b89a3c64bcb4bf8f5553befd15c1b388d954a8b995e21ecf9a1
  1.22--h96c455f_0:
    sha256:6d00e632bae58b7ebbc1e4419194afe51ffdf9c56bc964df808db4f4388038d1
  1.22.1--h96c455f_0:
    sha256:23dc2c29f457a448a0d341fb97b2632a2c8004925214cb6420562a5b12adf8a2
docker: quay.io/biocontainers/samtools
aliases:
  ace2sam: /usr/local/bin/ace2sam
  bgzip: /usr/local/bin/bgzip
  blast2sam.pl: /usr/local/bin/blast2sam.pl
  bowtie2sam.pl: /usr/local/bin/bowtie2sam.pl
  export2sam.pl: /usr/local/bin/export2sam.pl
  fasta-sanitize.pl: /usr/local/bin/fasta-sanitize.pl
  htsfile: /usr/local/bin/htsfile
  interpolate_sam.pl: /usr/local/bin/interpolate_sam.pl
  libdeflate-gunzip: /usr/local/bin/libdeflate-gunzip
  libdeflate-gzip: /usr/local/bin/libdeflate-gzip
  maq2sam-long: /usr/local/bin/maq2sam-long
  maq2sam-short: /usr/local/bin/maq2sam-short
  md5fa: /usr/local/bin/md5fa
  md5sum-lite: /usr/local/bin/md5sum-lite
  novo2sam.pl: /usr/local/bin/novo2sam.pl
  plot-ampliconstats: /usr/local/bin/plot-ampliconstats
  plot-bamstats: /usr/local/bin/plot-bamstats
  psl2sam.pl: /usr/local/bin/psl2sam.pl
  sam2vcf.pl: /usr/local/bin/sam2vcf.pl
  samtools: /usr/local/bin/samtools
  samtools.pl: /usr/local/bin/samtools.pl
  seq_cache_populate.pl: /usr/local/bin/seq_cache_populate.pl
  soap2sam.pl: /usr/local/bin/soap2sam.pl
  tabix: /usr/local/bin/tabix
  wgsim: /usr/local/bin/wgsim
  wgsim_eval.pl: /usr/local/bin/wgsim_eval.pl
  zoom2sam.pl: /usr/local/bin/zoom2sam.pl
```

The `shpc pull` command is used to pull any container. We have a script named `install_containers.sh` that
is used to pull a collection of containers.

## SHPC Setting

There are few important configurations that are set for shpc, this can be found in `shpc/settings.yml` which
can be updated manually. 

The `module_base` keyword defines where modules are generated. 

```console
(.pyenv) [spack@login singularity-hpc]$ shpc config get module_base
/camber/home/tools/shpc/modules
```

The keyword `container_base` defines where containers are stored

```console
(.pyenv) [spack@login singularity-hpc]$ shpc config get container_base
/camber/home/tools/shpc/containers
```

You will see that containers are stored by their URI

```console
(.pyenv) [spack@login singularity-hpc]$ ls -l /camber/home/tools/shpc/containers
total 8
drwxr-xr-x 3 spack spack 6144 Aug  8 18:34 python
drwxr-xr-x 3 spack spack 6144 Aug  8 18:38 quay.io

(.pyenv) [spack@login singularity-hpc]$ ls -l /camber/home/tools/shpc/containers/python
total 4
drwxr-xr-x 2 spack spack 6144 Aug  8 18:35 3.9
(.pyenv) [spack@login singularity-hpc]$ ls -l /camber/home/tools/shpc/containers/python/3.9
total 337612
-rwxr-xr-x 1 spack spack 345714688 Aug  8 18:35 python-3.9-sha256:74d428e4999a28c9c806964afe3126b64a761d3c49ced57bdace58dc5ae8b869.sif
```

shpc has a feature for splicing set of installed modules into a [view](https://singularity-hpc.readthedocs.io/en/latest/getting_started/user-guide.html#views)
we are using a single view. We have setup a default view set by keyword `default_view`

```console
(.pyenv) [spack@login singularity-hpc]$ shpc config get default_view
apps
```

You can see list of available view via 

```console
(.pyenv) [spack@login singularity-hpc]$ shpc view list
                          apps
```

Whenever you pull a container, shpc will also install module in the view, you can use the `shpc view get <view_name>`
to get path to view where modules are created

```console
(.pyenv) [spack@login singularity-hpc]$ shpc view get apps
/camber/home/tools/shpc/singularity-hpc/views/apps
```

We can run the `tree` command to see a directory overview of all the containers, take note that the view
will have symbolic link to modules which are actually stored in directory defined by setting `module_base`

```console
(.pyenv) [spack@login singularity-hpc]$ tree $(shpc view get apps)
/camber/home/tools/shpc/singularity-hpc/views/apps
├── bcftools
│   └── 1.22--h3a4d415_1.lua -> /camber/home/tools/shpc/modules/quay.io/biocontainers/bcftools/1.22--h3a4d415_1/module.lua
├── bedtools
│   └── 2.31.1--h13024bc_3.lua -> /camber/home/tools/shpc/modules/quay.io/biocontainers/bedtools/2.31.1--h13024bc_3/module.lua
├── biobb_amber
│   └── 5.1.0--pyhdfd78af_0.lua -> /camber/home/tools/shpc/modules/quay.io/biocontainers/biobb_amber/5.1.0--pyhdfd78af_0/module.lua
├── blast
│   └── 2.16.0--h66d330f_5.lua -> /camber/home/tools/shpc/modules/quay.io/biocontainers/blast/2.16.0--h66d330f_5/module.lua
├── bowtie2
│   └── 2.5.4--he96a11b_6.lua -> /camber/home/tools/shpc/modules/quay.io/biocontainers/bowtie2/2.5.4--he96a11b_6/module.lua
├── bwa
│   └── 0.7.19--h577a1d6_1.lua -> /camber/home/tools/shpc/modules/quay.io/biocontainers/bwa/0.7.19--h577a1d6_1/module.lua
├── fastqc
│   └── 0.12.1--hdfd78af_0.lua -> /camber/home/tools/shpc/modules/quay.io/biocontainers/fastqc/0.12.1--hdfd78af_0/module.lua
├── freebayes
│   └── 1.3.10--hbefcdb2_0.lua -> /camber/home/tools/shpc/modules/quay.io/biocontainers/freebayes/1.3.10--hbefcdb2_0/module.lua
├── gatk4
│   └── 4.6.2.0--py310hdfd78af_0.lua -> /camber/home/tools/shpc/modules/quay.io/biocontainers/gatk4/4.6.2.0--py310hdfd78af_0/module.lua
├── hisat2
│   └── 2.2.1--h503566f_8.lua -> /camber/home/tools/shpc/modules/quay.io/biocontainers/hisat2/2.2.1--h503566f_8/module.lua
├── picard
│   └── 3.4.0--hdfd78af_0.lua -> /camber/home/tools/shpc/modules/quay.io/biocontainers/picard/3.4.0--hdfd78af_0/module.lua
├── portcullis
│   └── 1.2.4--py39hc12ff1f_3.lua -> /camber/home/tools/shpc/modules/quay.io/biocontainers/portcullis/1.2.4--py39hc12ff1f_3/module.lua
├── prokka
│   └── 1.14.6--pl5321hdfd78af_5.lua -> /camber/home/tools/shpc/modules/quay.io/biocontainers/prokka/1.14.6--pl5321hdfd78af_5/module.lua
├── quast
│   └── 5.3.0--py313pl5321h5ca1c30_2.lua -> /camber/home/tools/shpc/modules/quay.io/biocontainers/quast/5.3.0--py313pl5321h5ca1c30_2/module.lua
├── samtools
│   └── 1.22.1--h96c455f_0.lua -> /camber/home/tools/shpc/modules/quay.io/biocontainers/samtools/1.22.1--h96c455f_0/module.lua
├── slow5tools
│   └── 1.3.0--hee927d3_1.lua -> /camber/home/tools/shpc/modules/quay.io/biocontainers/slow5tools/1.3.0--hee927d3_1/module.lua
├── spades
│   └── 4.2.0--h8d6e82b_1.lua -> /camber/home/tools/shpc/modules/quay.io/biocontainers/spades/4.2.0--h8d6e82b_1/module.lua
├── star
│   └── 2.7.11b--h5ca1c30_6.lua -> /camber/home/tools/shpc/modules/quay.io/biocontainers/star/2.7.11b--h5ca1c30_6/module.lua
├── trimmomatic
│   └── 0.39--hdfd78af_2.lua -> /camber/home/tools/shpc/modules/quay.io/biocontainers/trimmomatic/0.39--hdfd78af_2/module.lua
├── vcftools
│   └── 0.1.17--pl5321h077b44d_0.lua -> /camber/home/tools/shpc/modules/quay.io/biocontainers/vcftools/0.1.17--pl5321h077b44d_0/module.lua
└── view.yaml

20 directories, 21 files
```

## Production Deployment

We have a github workflow file https://github.com/CamberCloud-Inc/spack-infra/blob/main/.github/workflows/containers.yml
that will automatically trigger an action to run script for installing container, if you want to add a container simply edit
the file `install_containers.sh` with the desired container. This will automatically create the modules and no additional work
is needed.

You can load the `biocontainers` module which sets `MODULEPATH` to expose the software. You will see a list 
of modules that are coming from shpc containers

```console
(.pyenv) [spack@login singularity-hpc]$ ml av

-------------------------------------------------------------------- /camber/home/tools/shpc/singularity-hpc/views/apps --------------------------------------------------------------------
   bcftools/1.22--h3a4d415_1          bowtie2/2.5.4--he96a11b_6       gatk4/4.6.2.0--py310hdfd78af_0      prokka/1.14.6--pl5321hdfd78af_5       spades/4.2.0--h8d6e82b_1
   bedtools/2.31.1--h13024bc_3        bwa/0.7.19--h577a1d6_1          hisat2/2.2.1--h503566f_8            quast/5.3.0--py313pl5321h5ca1c30_2    star/2.7.11b--h5ca1c30_6
   biobb_amber/5.1.0--pyhdfd78af_0    fastqc/0.12.1--hdfd78af_0       picard/3.4.0--hdfd78af_0            samtools/1.22.1--h96c455f_0           trimmomatic/0.39--hdfd78af_2
   blast/2.16.0--h66d330f_5           freebayes/1.3.10--hbefcdb2_0    portcullis/1.2.4--py39hc12ff1f_3    slow5tools/1.3.0--hee927d3_1          vcftools/0.1.17--pl5321h077b44d_0
```

You can inspect one of these containers just by showing the content of the container, let's say you want to try `samtools`, if
you run `module show samtools`, you will see some metadata and some variables such as `SINGULARITY_CONTAINER` 
that can be used to reference the container. The shpc tool will create commands aliases for programs that
will run `singularity run` or `singularity exec` in the container without you ever knowing its a container.

```console
(.pyenv) [spack@login singularity-hpc]$ ml show samtools
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
   /camber/home/tools/shpc/singularity-hpc/views/apps/samtools/1.22.1--h96c455f_0.lua:
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
help([[This module is a singularity container wrapper for quay.io/biocontainers/samtools:1.22.1--h96c455f_0 v1.22.1--h96c455f_0


Container (available through variable SINGULARITY_CONTAINER):

 - /camber/home/tools/shpc/containers/quay.io/biocontainers/samtools/1.22.1--h96c455f_0/quay.io-biocontainers-samtools-1.22.1--h96c455f_0-sha256:23dc2c29f457a448a0d341fb97b2632a2c8004925214cb6420562a5b12adf8a2.sif

Commands include:

 - samtools-run:
       singularity run -B <wrapperDir>/99-shpc.sh:/.singularity.d/env/99-shpc.sh <container> "$@"
 - samtools-shell:
       singularity shell -s /bin/sh -B <wrapperDir>/99-shpc.sh:/.singularity.d/env/99-shpc.sh <container>
 - samtools-exec:
       singularity exec -B <wrapperDir>/99-shpc.sh:/.singularity.d/env/99-shpc.sh <container> "$@"
 - samtools-inspect-runscript:
       singularity inspect -r <container>
 - samtools-inspect-deffile:
       singularity inspect -d <container>
 - samtools-container:
       echo "$SINGULARITY_CONTAINER"
```

Let's try loading the container and inspect the content of `samtools`, you will notice that this command will
run a `singularity exec` command for the samtools container and run `/usr/local/bin/samtools` with any additional arguments, 
take note that `/usr/local/bin/samtools` is the actual location where samtools is installed in the container.

```console
(.pyenv) [spack@login singularity-hpc]$ ml samtools
(.pyenv) [spack@login singularity-hpc]$ cat $(which samtools)
#!/bin/bash

script=`realpath $0`
wrapperDir=`dirname $script`/..

singularity ${SINGULARITY_OPTS} exec ${SINGULARITY_COMMAND_OPTS} -B $wrapperDir/99-shpc.sh:/.singularity.d/env/99-shpc.sh   /camber/home/tools/shpc/containers/quay.io/biocontainers/samtools/1.22.1--h96c455f_0/quay.io-biocontainers-samtools-1.22.1--h96c455f_0-sha256:23dc2c29f457a448a0d341fb97b2632a2c8004925214cb6420562a5b12adf8a2.sif /usr/local/bin/samtools "$@"
```

Let's run `samtools version`, as you can see we are running a samtools inside the container

```console
(.pyenv) [spack@login singularity-hpc]$ samtools version
samtools 1.22.1
Using htslib 1.22.1
Copyright (C) 2025 Genome Research Ltd.

Samtools compilation details:
    Features:       build=configure curses=yes
    CC:             /opt/conda/conda-bld/samtools_1752528053426/_build_env/bin/x86_64-conda-linux-gnu-cc
    CPPFLAGS:       -DNDEBUG -D_FORTIFY_SOURCE=2 -O2 -isystem /usr/local/include
    CFLAGS:         -Wall -march=nocona -mtune=haswell -ftree-vectorize -fPIC -fstack-protector-strong -fno-plt -O2 -ffunction-sections -pipe -isystem /usr/local/include -fdebug-prefix-map=/opt/conda/conda-bld/samtools_1752528053426/work=/usr/local/src/conda/samtools-1.22.1 -fdebug-prefix-map=/usr/local=/usr/local/src/conda-prefix
    LDFLAGS:        -Wl,-O2 -Wl,--sort-common -Wl,--as-needed -Wl,-z,relro -Wl,-z,now -Wl,--disable-new-dtags -Wl,--gc-sections -Wl,--allow-shlib-undefined -Wl,-rpath,/usr/local/lib -Wl,-rpath-link,/usr/local/lib -L/usr/local/lib
    HTSDIR:
    LIBS:
    CURSES_LIB:     -ltinfow -lncursesw

HTSlib compilation details:
    Features:       build=configure libcurl=yes S3=yes GCS=yes libdeflate=yes lzma=yes bzip2=yes plugins=yes plugin-path=/usr/local/libexec/htslib htscodecs=1.6.4
    CC:             /opt/conda/conda-bld/htslib_1752522550715/_build_env/bin/x86_64-conda-linux-gnu-cc
    CPPFLAGS:       -DNDEBUG -D_FORTIFY_SOURCE=2 -O2 -isystem /usr/local/include
    CFLAGS:         -Wall -march=nocona -mtune=haswell -ftree-vectorize -fPIC -fstack-protector-strong -fno-plt -O2 -ffunction-sections -pipe -isystem /usr/local/include -fdebug-prefix-map=/opt/conda/conda-bld/htslib_1752522550715/work=/usr/local/src/conda/htslib-1.22.1 -fdebug-prefix-map=/usr/local=/usr/local/src/conda-prefix -fvisibility=hidden
    LDFLAGS:        -Wl,-O2 -Wl,--sort-common -Wl,--as-needed -Wl,-z,relro -Wl,-z,now -Wl,--disable-new-dtags -Wl,--gc-sections -Wl,--allow-shlib-undefined -Wl,-rpath,/usr/local/lib -Wl,-rpath-link,/usr/local/lib -L/usr/local/lib -fvisibility=hidden -rdynamic

HTSlib URL scheme handlers present:
    built-in:	 file, preload, data
    S3 Multipart Upload:	 s3w+https, s3w+http, s3w
    Amazon S3:	 s3+https, s3, s3+http
    libcurl:	 gophers, smtp, wss, smb, rtsp, tftp, pop3, smbs, imaps, pop3s, ws, ftps, https, ftp, gopher, sftp, imap, http, smtps, scp, dict, mqtt, telnet
    Google Cloud Storage:	 gs+http, gs+https, gs
    crypt4gh-needed:	 crypt4gh
    mem:	 mem
```

Anytime you load an sphc module, it will set an environment `SINGULARITY_CONTAINER` which can be used to reference the container

```console
(.pyenv) [spack@login singularity-hpc]$ echo $SINGULARITY_CONTAINER
/camber/home/tools/shpc/containers/quay.io/biocontainers/samtools/1.22.1--h96c455f_0/quay.io-biocontainers-samtools-1.22.1--h96c455f_0-sha256:23dc2c29f457a448a0d341fb97b2632a2c8004925214cb6420562a5b12adf8a2.sif
```

You can run arbitrary commands inside container such as the following

```console
(.pyenv) [spack@login singularity-hpc]$ $SINGULARITY_CONTAINER which samtools
/usr/local/bin/samtools
```