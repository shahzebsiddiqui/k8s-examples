sudo setenforce 0
/usr/sbin/create-munge-key
dnf localinstall -y  $HOME/rpmbuild/RPMS/x86_64/{slurm,slurm-example-configs,slurm-slurmctld,slurm-slurmdbd,slurm-perlapi}-25.05.5-1.el9.x86_64.rpm
systemctl restart munge
chown -R slurm:slurm /etc/slurm
cp slurm.conf /etc/slurm/slurm.conf
cp slurmdbd.conf /etc/slurm/slurmdbd.conf
systemctl enable --now slurmctld
systemctl enable --now slurmdbd 
systemctl enable --now slurmd

