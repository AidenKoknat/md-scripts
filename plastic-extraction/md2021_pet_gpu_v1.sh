#!/bin/bash
source /data/ulab222/gromacs-2021.2/bin/GMXRC
options_md="-ntmpi 1 -ntomp 4 -nb gpu -pme gpu"

# This script is for water systems with plastic. It runs a GROMACS md simulation using LibParGen files
# $1 is the name of the plastic gro file e.g PET
# $name$c is the solvated gro file, $one is the Energy minimization mdp,
# $two is the NPT mdp, $three is the production mdp
# example:  nohup ./md2021_pet.sh PET WAT 1 7.0 0.2 > output.log 2>&1 &
name=$1-$2
one=1
two=2
three=3
c='_boxed'
d='_em'
e='_npt'
f='_md'
m='_msd'
r='_rdf'
n="_numbered"
g="_centered"

mover(){
	mkdir $1
	mv *xvg ./$1
}


gmx_gpu insert-molecules -ci $1.gro -o $name.gro -nmol $3 -box 1.0
gmx_gpu editconf -f $name.gro -o $name$g.gro -box $4 -c
gmx_gpu solvate -cp $name$g.gro  -cs tip4p.gro -o $name$c.gro -p $name.top

# Energy minimization
gmx_gpu  grompp -f $one.mdp -c $name$c.gro  -r $name$c.gro -p $name.top -o $name$d.tpr
echo 'EM grompp done'
gmx_gpu mdrun -deffnm $name$d
echo 'EM mdrun done'

# NPT Equilibration
gmx_gpu  grompp -f $two.mdp -c $name$d.gro -p $name.top -r $name$c.gro -o $name$e.tpr
echo 'NPT grompp done'
gmx_gpu mdrun -deffnm $name$e $options_md
echo 'NPT mdrun done'


# Production run
gmx_gpu  grompp -f $three.mdp -c $name$e.gro -p $name.top -o $name$f.tpr
gmx_gpu mdrun -v -deffnm $name$f $options_md
#gmx_gpu convert-tpr -s $name$f.tpr -nsteps 100000000 -o $name$f$two.tpr
#gmx_gpu mdrun -v -s $name$f$two -o $name$f.trr -c $name$f.gro -e $name$f.edr -g $name$f.log $options_md -cpi state.cpt
echo 'MD done'

#plumed --no-mpi sum_hills --hills HILLS
