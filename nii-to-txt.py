#! /usr/bin/env python
# META =========================================================================
# Title: nii-to-txt.sh
# Usage: nii-to-txt.sh
# Description: Convert nifti image volume to text files.
# Author: Colin D. Shea
# Created: 2016-03-01
# ==============================================================================
# Prerequisites: 
# nibabel   - (http://nipy.org/nibabel/)
#         Nifti module; used to determine dimensions/resolutions
# ==============================================================================

# TODO
#   make slice selection interactive?
#   normalize intensities with interactive window and level
#   output to proper image viewer instead of text file

# Imports
import os
import nibabel
import numpy

# set input dir and file
nii_dir=os.path.abspath("D:/Pipeline/MNI")
nii_file=os.path.join(nii_dir, "MNI152_T1_1mm_brain.nii.gz")
txt_file=os.path.abspath("C:/Users/sheacd/mni.txt")

# load nii as image and header with nibabel
nii_img=nibabel.load(nii_file)
nii_data=nii_img.get_data()
nii_hdr=nii_img.get_header()

header=nii_hdr.__dict__['_structarr']
num_dims=header['dim'][0]+1
dims=header['dim'][1:num_dims]
pixdims=header['pixdim'][1:num_dims]

# normalize intensity values to 8-bit (256) range
nii_data=numpy.multiply( nii_data, (256.0/nii_data.max()) )

# transpose x,y,z according RAS+ convention
#   need to confirm swap + flip produces output with correct handedness
# mni template saved in mni space
# swap x,y
nii_swap=numpy.swapaxes(nii_data,0,1)
# flip y
nii_flip=numpy.flipud(nii_swap)
# print header dims
print dims 
# convert numpy array nii_data to text
numpy.savetxt( txt_file, nii_flip[:,:,91], fmt='%4.0f')
