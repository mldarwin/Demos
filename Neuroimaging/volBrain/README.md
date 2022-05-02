Requirements: 
1) volBrain_region_key.csv on path
2) Access to Research drive with STMP##_CT_ESeg.nii & native_structures_job#####.nii.gz files available

---Function 'volBrain'---
 
Localize SEEG electrode contact to specific brain region

Inputs: 1) Patient ID, 2) Contact of interest

Example: volBrain('STMP83', 603)

Outputs: elecContact = a table with:
contact #, brain regions contact is in, hemispheres, & matter type


Marielle L. Darwin | Lisa Hirt | John A. Thompson | April 29 2022
