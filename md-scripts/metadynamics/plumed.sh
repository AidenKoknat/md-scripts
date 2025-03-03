#!/bin/bash
source /data/ulab222/gromacs-2021.2/bin/GMXRC
options_md="-ntmpi 1 -ntomp 10 -nb gpu -pme gpu"

# This script is for DES-DES systems. It runs a GROMACS md simulation using LibParGen files
# $1 is the name of the merged gro file e.g ThyLid11-MenLid11
# $name$c is the boxed gro file, $one is the Energy minimization mdp,
# $two is the NPT mdp, $three is the production mdp

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

mover(){
	mkdir $1
	mv *xvg ./$1
}


gmx_gpu insert-molecules -ci $1.gro -o $name.gro -nmol $3 -box $4 -radius $5
#gmx_gpu editconf -f $name$f.gro -o $name$i.gro -box $x $y $z -noc
gmx_gpu solvate -cp $name.gro  -cs tip4p.gro -o $name$c.gro -p $name.top

# Energy minimization
gmx_gpu  grompp -f $one.mdp -c $name$c.gro -p $name.top -o $name$d.tpr
echo 'EM grompp done'
gmx_gpu mdrun -deffnm $name$d
echo 'EM mdrun done'

# NPT Equilibration
gmx_gpu  grompp -f $two.mdp -c $name$d.gro -p $name.top -o $name$e.tpr
echo 'NPT grompp done'
gmx_gpu mdrun -deffnm $name$e $options_md
echo 'NPT mdrun done'


# Production run
gmx_gpu  grompp -f $three.mdp -c $name$e.gro -p $name.top -o $name$f.tpr
gmx_gpu mdrun -v -deffnm $name$f -plumed plumed.dat $options_md
#gmx_gpu convert-tpr -s $name$f.tpr -nsteps 100000000 -o $name$f$two.tpr
#gmx_gpu mdrun -v -s $name$f$two -o $name$f.trr -c $name$f.gro -e $name$f.edr -g $name$f.log $options_md -cpi state.cpt
echo 'MD done'
