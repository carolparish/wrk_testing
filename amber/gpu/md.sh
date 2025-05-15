# 25ns of unrestrained MD at 300K for testing purposes
$AMBERHOME/bin/pmemd.cuda -O -i md.mdin -p Bound_iGluN2A_APO_solv.complex.prmtop -c Bound_iGluN2A_APO_eq7.rst7 -ref Bound_iGluN2A_APO_eq7.rst7 -o Bound_iGluN2A_APO_md001.mdout -r Bound_iGluN2A_APO_md001.rst7 -x Bound_iGluN2A_APO_md001.nc
