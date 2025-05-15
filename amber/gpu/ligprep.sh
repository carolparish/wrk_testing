/!/bin/bash

#Ligand preparation

$AMBERHOME/bin/antechamber -i glu.pdb -fi pdb -o glu.mol2 -fo mol2 -c bcc -s 2 -nc -2 -m 1 -j 5 -at gaff -dr no

# Run parmchk to generate a force field modification specific to the Bound_iGluN2A#_DRUG_Site#_Pose# being bound
###                        V change file name                     v change file name
$AMBERHOME/bin/parmchk2 -i glu.mol2 -f mol2 -o glu.frcmod

rm leap.in
cat > leap.in << EOF
###Load protein force field. The newest forcefield is ff19SB (only available from AMBER20 and beyond), which is also recommended by AMBER. https://ambermd.org/AmberModels_proteins.php
source leaprc.protein.ff14SB
###ONLY use this for ERpY because it has phophorylated re
source leaprc.gaff2
###load TIP3P (water) force field. This model is recommended to go with ff14SB forcefield (for ff19SB the water model is OPC.) https://pubs.acs.org/doi/10.1021/acs.jctc.9b00591
source leaprc.water.tip3p
###This step is to load the parameters for TIP3P ions.
loadamberparams frcmod.ionsjc_tip3p
###load protein pdb file. Make sure the PDB is cleaned up and gotten it ready to be read before loading it into PDB. The PDB file should just contain the atomic coordinate lines. Go ahead and remove all the information added by the X-ray crystallographer at the beginning of the file. This will make it less likely for tleap to have problems reading the file format
rec=loadpdb iGluN2A_APO.pdb
###load glutamate
glu=loadmol2 glu.mol2 
###create gas-phase complex (system with only solute, or "dry complex")
gascomplex= combine {rec glu}
###write gas-phase pdb
savepdb gascomplex Bound_iGluN2A_APO.gas.complex.pdb
###write gase-phase toplogy and coord files for MMGBSA calc
saveamberparm gascomplex Bound_iGluN2A_APO.gas.complex.prmtop Bound_iGluN2A_APO.gas.complex.inpcrd
saveamberparm rec receptor.gas.prmtop receptor.gas.inpcrd
saveamberparm glu glu.prmtop glu.inpcrd
###create solvated complex
###Neutralize system. The number of ions will be added after the charge of the system is determined. Tleap also gives warning about charge not being zero when we save prmtop/inpcrd files earlier so we can also use this information from tleap. This step is adding counter ions to neutralize the whole system (including both receptor and protein). We cannot use this to neutralize TIP3P because the model requires special parameters (accordind to AMBER20 lab manual).
addions gascomplex Cl- 0
addions gascomplex Na+ 0
###               V change file names                V change file names
saveamberparm gascomplex Bound_iGluN2A_APO_ions.prmtop Bound_iGluN2A_APO_ions.inpcrd
###solvate the system
solvateoct gascomplex TIP3PBOX 12.0
###write solvated toplogy and coordinate file
saveamberparm gascomplex Bound_iGluN2A_APO_solv.complex.prmtop Bound_iGluN2A_APO_solv.complex.inpcrd
quit
EOF

# Run leap.in file
$AMBERHOME/bin/tleap -f leap.in

# Generate a 0ns PDB of the simulation you're about to run. This is necessary to make sure tLeap ran properly. Always visualize this structure in Chimera or some other visualization software before running MD. It is useful for imaging later on.
rm cpptraj_inpcrd.in
cat > cpptraj_inpcrd.in << EOF
parm Bound_iGluN2A_APO_solv.complex.prmtop
trajin Bound_iGluN2A_APO_solv.complex.inpcrd

autoimage
strip :WAT:Cl-:Na+
trajout Bound_iGluN2A_APO_0ns.pdb
go
EOF

# Run cpptraj.in file
$AMBERHOME/bin/cpptraj -i cpptraj_inpcrd.in
