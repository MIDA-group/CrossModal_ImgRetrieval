#@String(value='The path to all images.') path
#@String(value='Verbosity.') verbose 

# This scripts calculates SIFT features.
# It is possible to change the parameters of the
# algorithm in the code below. The result is outputted in  CSV files.
# Script mostly modified from: https://www.ini.uzh.ch/~acardona/fiji-tutorial/#feature-extraction-sift-similarity
#
# Example:
# $fiji --ij2 --headless --run compute_sift.py 'path="imageA.png"'
#
# Notes:
# * It is possible to feed paths with wildcards in them, e.g.: /path/A/*.png
# * In the case of a list, images are sorted alphabetically.

# Python standard library
import glob
import sys
import os
# ImageJ related
from ij import IJ
from mpicbg.imagefeatures import FloatArray2DSIFT, FloatArray2D
from mpicbg.models import PointMatch, RigidModel2D, NotEnoughDataPointsException
# Java imports
from java.lang import Double
from java.lang.reflect.Array import newInstance as newArray
from java.lang import System
#print(sys.version_info)


# Loading the path of all images + sanity check
list1 = [i for i in sorted(glob.glob(path)) if os.path.isfile(i)] # folder may contain other folders (like features). Ignore those.
N = len(list1)

verbos = eval(verbose.capitalize()) #verbose comes in through command line as string

workingfolder = os.path.basename(os.path.dirname(list1[0])) #get parent folder name
if not verbos:
    print("\nCalculating SIFT features on {}...".format(workingfolder))

for i in range(N):
    if verbos:
        print
        print("+========================================================+")
        print("| Calculation of SIFT feats on image {: 4d} / {: 4d}     |".format(i+1, N))
        print("+========================================================+")

        # Loading the pair of images
        print("Loading the image...")
    imp1 = IJ.openImage(list1[i])
    #print(imp1)

    # Parameters for SIFT: NOTE 4 steps, larger maxOctaveSize
    p = FloatArray2DSIFT.Param()
    p.fdSize = 4 # number of samples per row and column
    p.fdBins = 8 # number of bins per local histogram
    p.maxOctaveSize = 512 #1024 # largest scale octave in pixels
    p.minOctaveSize = 32 #128   # smallest scale octave in pixels
    p.steps = 4 # number of steps per scale octave
    p.initialSigma = 1.6

    def extractFeatures(ip, params):
        sift = FloatArray2DSIFT(params)
        sift.init(FloatArray2D(ip.convertToFloat().getPixels(),
                                ip.getWidth(), ip.getHeight()))
        features = sift.run() # instances of mpicbg.imagefeatures.Feature
        return features
    if verbos:
        print("Extracting SIFT features...")
    features = extractFeatures(imp1.getProcessor(), p)

    # Resulting CSV file
    # The results will be stored in a csv file
    result = list1[i][:-4] + ".csv" 
    if verbos:
        print("Found %d points. Saving to %s" %(len(features), result))

    f = open(result, "w")
    # The transformation matrix is saved in math format (y-axis first, then x-axis)
    f.write("x,y, scale, orientation, descriptor\n")


    for line in features: 
        f.write("%f,%f,%f,%f" %(line.location[0], line.location[1], line.scale, line.orientation))
        for j in range(len(line.descriptor)):
            f.write(",%f" % line.descriptor[j])
        f.write("\n")
        #print(line.descriptor)

    f.close()
    # Closing the images and freeing the memory
    imp1.close()


print("DONE. \n")
 

