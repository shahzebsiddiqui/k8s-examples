#!/bin/bash
SLURM_USER="slurm"
SLURM_GROUP="slurm"
SLURM_USERID=9999
SLURM_GID=9999
groupadd -g $SLURM_GID $SLURM_GROUP
useradd -r -u $SLURM_USERID -g $SLURM_GROUP -c "Slurm workload manager" -d /var/lib/slurm -s /bin/false $SLURM_USER
mkdir -p /var/spool/slurmctld /var/log/slurm /var/lib/slurm
chown -R $SLURM_USER:$SLURM_GROUP /var/spool/slurmctld /var/log/slurm /var/lib/slurm
chmod 755 /var/spool/slurmctld /var/log/slurm
