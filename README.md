# Cross-Modality Sub-Image Retrieval using Contrastive Multimodal Image Representations

Code of our paper: [Cross-Modality Sub-Image Retrieval using Contrastive Multimodal Image Representations]

 [Pre-print version on arXiv](https://arxiv.org/abs/2201.03597)


## Table of Contents

- [Introduction](#introduction)
- [How does it work?](#how-does-it-work)
- [Key findings of the paper](#key-findings-of-the-paper)
- [Datasets](#datasets)
- [Creation of CBIR](#creation-of-cbir)
- [Scripts](#scripts)
- [Citation](#citation)


## Introduction
Multimodal imaging is a powerful tool used for many tissue characterizations as well as cancer diagnostics. The developments in the field of Digital Pathology make it possible that large datasets can be automatically acquired. To make these datasets searchable and allow for side-by-side examination of images in different modalities, content-based image retrieval (CBIR) systems are needed to index the datasets, and allow for retrieval and registration. We propose a CBIR pipeline which learns common representations for both input modalities and creates a bag of words for efficient retrieval of images in modality A, given its corresponding, rigidly transformed image or subimage in modality B. The method is general, does neither rely on data-specific information, nor image labels, and was evaluated on a challenging dataset of brightfield microscopy and second harmonic generation images.

<p align="center">
  <img src="resources/ImgRetrieval.png" width=700 />
</p>

This repository provides the code needed to preform reverse image search between two sets of images. Any image in the first set can be used as a query to find its counterpart in the second set of images, and vice versa. The method requires no image labels. All code in this repository is written in Matlab 2021b. 
The code in this repository has been developed to allow for image retrieval across two different modalities. Contrastive Representation Learning is used to learn dense representations called CoMIRs, which map the original images into an abstract representation space. The (python) code needed to generate CoMIRs is given in [CoMIR Github Repo](https://github.com/MIDA-group/CoMIR/blob/90a4c919b853c090c602d2ca73ba87ddf6b01318/readme.md).

## How does it work?
The proposed CBIR method consists of three stages: (i) it first learns rotationally equivariant representations called CoMIRs using contrastive learning as introduced in Pielawski, Wetzer et al (2020) to bridge the semantic gap between the different modalities; (ii) it creates a bag-of-words (BoW) based on SURF features; (ii) and finally it uses re-ranking to refine the retrieval among the best-ranking matches. The pipeline is shown in the following figure.

<p align="center">
  <img src="resources/pipeline.png" width=700 />
</p>

## Key findings of the paper
This repo provides code for the reverse image search across rigidly unaligned modalities, and evaluates it on BF and SHG microscopy images used in histopathology. Our study showed that CoMIRs are usable representations for cross-modality image retrieval. The requirement for rotationally equivariant representations was highlighted, as well as the rotational and translational invariance of the feature extractor applied to them to create the BoW. Re-ranking proved itself as a useful tool to boost the retrieval performance. 
The proposed combination of CoMIR representations and SURF features together with re-ranking reaches a 75.4\% top-10 success rate to retrieve BF query images in a set of SHG images, and 83.6\% to retrieve SHG query images within the set of BF images, combining the power of deep learning and robust, classical methods.

## Datasets
We used the following publicly available dataset:
* Multimodal Biomedical Dataset for Evaluating Registration Methods: https://zenodo.org/record/3874362

## Creation of CBIR
To retrieve images in modality A corresponding to a query patch in modality B, we design a CBIR which acts as a query-by-example search to perform a reverse image search.  To do so, we transform the original images in modality A and B to abstract image representations, called CoMIRs. Next, we extract features from these CoMIRs, which we index by creating a Bag of Words. Finally the database is search in the retrieval step and the retrieval result is improved by a re-ranking step.

### Part 1: Generation of CoMIRs
In Pielawski, Wetzer et al. (NeurIPS 2020), a method was introduced which uses a contrastive loss to generate representations called CoMIRs. One CoMIR is created per input modality, using two identical U-Nets which are coupled by a contrastive loss. The CoMIRs of two corresponding images in BF and SHG are learnt such that they are similar with respect to a similarity measure, in this study mean squared error. Furthermore, CoMIRs are equivariant to rotation. Hyperparameters are chosen as in Pielwaski, Wetzer et al. The resulting 1-channel CoMIRs are saved in .tif format and used to create the CBIR. The (python) code needed to generate CoMIRs is given in [CoMIR Github Repo](https://github.com/MIDA-group/CoMIR/blob/90a4c919b853c090c602d2ca73ba87ddf6b01318/readme.md).

### Part 2: Feature Extraction
We test two sparse feature extractors (SIFT, SURF) and one dense feature extractor (pretrained ResNET152). 
The size of the SIFT descriptor is 4 samples per row and column with 8 bins per local histogram. The range of the scale octaves is [32,512] pixels, using 4 steps per octave and an initial sigma of 1.6 for each scale octave. Fiji was used for SIFT extraction. 
As SURF features, upright multiscale features are extracted in Matlab for patches of size 32, 64, 96 and 128 on a grid with spacing [8,8].
ResNet152 was pretrained on ImageNet and the features are extracted by removing the last fully connected layer and using an adaptive average pooling to result in features of size 8x8, i.e. 64 after flattening. In order to faciliate the one channel SHG images, the input is copied into three layers.

### Part 3: Creation of Bag of Words
The features extracted in the previous step are used to form a vocabulary of 2000 words. For each modality a BoW is formed using the entire training set (implemented in Matlab). The fraction of strongest features is set to 0.8, and cosine similarity is chosen to match the histograms/words in the BoWs across modalities.

### Part 4: Retrieval and Re-Ranking
Retrieval is performed by matching the histograms using cosine similarity. To further improve the retrieval results, the best ranked matches are re-ranked by taking a number of top retrieval matches and cut them into patches of the same size as the query (in case of full-image search, the entire image is used). The resulting patches form a database for which a new (s-)CBIR ranking is computed, using the same configuration as the initial one.

## Scripts
We provide scripts for running individual parts of the proposed pipeline manually: consult section **Running manually** for detailed explanation and use examples. In addition, we provide a make file for an automated running of the pipeline: see section **Running with make** for more information. 

Regardless of how you decide to use the provided code, there are a few steps that need to be done in advance. First, clone this repository or download its code to your computer. The provided folder structure is required when running with make (and not required but strongly suggested even when running individual scripts and functions):  

<pre>
CrossModal_ImgRetrieval
├── resources
├── utils
├── data
│   ├── modality1
│   │   ├── ... save your images of modality 1 in here
│   │   └── features
│   |       └── ... (extracted feature data will be saved here)
│   └── modality2
│       ├── ... save your images of modality 2 in here
│       └── features
│           └── ... (extracted feature data will be saved here)
├── results
│   └── ... (results of retrieval evaluations will be saved here)
├── Fiji.app
│   └── ... install fiji here
├── README.md
├── LICENSE
├── requirements.txt
├── imageretrieval.make
├── main_script.m
├── resnet_features.py
├── compute_sift.py
├── EvalMatches.m
└── RetrieveMatches.m
</pre>

That is, save your data into the data folder, with different modalities in different folders. 
Next, make sure you have all the required tools and libraries installed: 

- to create CoMIRs please follow the instructions on the [original CoMIR repository](https://github.com/MIDA-group/CoMIR). (The same repository also contains the code for creating GAN fakes as used in our paper.)
- if you wish to use sift as a feature extractor, download [FIJI](https://imagej.net/software/fiji/downloads) and save the folder Fiji.app in the same folder as the code resides. 
- if you wish to use (pretrained) resnet as a feature extractor, you need to have python3 installed, together with the packages in the provided requirements.txt file (you can do this for example by calling  `pip install -r requirements.txt` in your command line).
- to run retrieval and reranking steps (as well as a crude way of retrieval evaluation), you need to have [MATLAB](https://se.mathworks.com/) or [OCTAVE](https://octave.org/download) installed. *WARNING: as of september 2022 the implementation works only with MATLAB!*

### Running with make
In the *imageretrieval.make* file set the parameters to desired values. Then call  

```make -f imageretrieval.make```. 

By default it will run the entire pipeline (except the creation of CoMIRs - all the data needs to be prepared in advance and residing in correct folders!).  

If you wish to tun only parts of the pipeline, simply delete the names of the modules you do not wish to (re)run from the *all* target in the makefile: 
``` all: features retrieval reranking  ```.
But (!) observe that if the required prerequisites for the individual modules don't exist (for example, reranking needs the retrieval csv results to be able to run), the modules that produce the prerequisites will inevitably be run again. 

Observe also that the proposed folder structure needs to be kept in order for this to work. The folders with features and results will be created automatically (if not existing already) during the run of make. 


### Running manually
##### The proposed pipeline steps

1. **Creating CoMIRs:** Use the code and follow the steps [here](https://github.com/MIDA-group/CoMIR). Save the folder with obtained CoMIRs inside the data folder, as a new modality. 

2. **Extracting SURF features and creating a bag of features:**  
Run the following commands in MATLAB/OCTAVE, using the correct path name (if you follow the proposed directory structure, that would be 'data/modality1') and desired vocabulary size *vocab*.

         imgstorage = imageDatastore(path/to/modality1); 
         bof = indexImages(imgstorage, bagOfFeatures(imgstorage, 'VocabularySize', vocab), 'SaveFeatureLocations', true);

3. **Do retrieval:** 
Use the bag of features you have created; if you wish to query images from 'path/to/modality2' and get the first *nr_retrievals* matches for each query, run the code below in Matlab. It returns a string table of size *nr_queries X nr_retrievals*, with every row containing names of the first retrieved matches for that query.  
        
        matches = RetrieveMatches(path/to/modality2, bof, nr_retrievals);
         
         
4. **Reranking:** TODO




Important: To do both bag of feature creation and retrieval (and if desired evaluation) directly, you can also simply run the matlab script *main_script.m* (but uncomment and set the variables  first). The code for the evaluation step to reproduce the results in the paper is strictly speaking not the part of the proposed pipeline. For details on how to do it see steps for comparison below.  


##### Other steps we used for comparisons

1. **Creating pix2pix or cycleGAN fakes**: you can use the code available from the same repository as [CoMIR code](https://github.com/MIDA-group/CoMIR). Again, save the folder with newly created fakes as a new modality folder inside the data folder.

2. **Extracting SIFT features:** Run the *compute_sift.py* script via fiji. This is done by running the following command in the command line: 

        path/to/fiji --ij2 --headless --console --run compute_sift.py 'path="path/to/modality1", verbose="true"'

   Where the *path/to/fiji* should be substituted by the path to your fiji download and *path/to/modality* by the path to the folder with your images. If you observe the suggested directory structure and run on linux, those would for example be './Fiji.app/ImageJ-linux64' and './data/modality1' respecitvely. Set verbose to false if you want less verbosity. The sift features will be saved in csv files, inside your image data folder. So you need to manually move them to a new folder on the path 'data/modality1/features/sift'. 


3. **Extracting RESNET features:** Run the *resnet_features.py* script (make sure all the requirements in *requirements.txt* are satisfied first) by calling

        python3 resnet_features.py --data=data/modality --outpath=data/modality/features/resnet 
 
   with suitable path names from the command line. The resulting csvs with the extracted feature data for all the images in 'data/modality' will be saved in 'data/modality/features/resnet'.
   
4. **Creating a bag of features on SIFT or RESNET features:** The bag of words is in this case created on the csv files with the feature data. This is done by calling (in Matlab): 

        bof = getBOF('path/to/features', vocab, features, verbose);
       
   with 'path/to/features/' being the path to the folder that contains the required csv files, *vocab* the desired vocabulary size, features a string of 'sift' or 'resnet', depending on which features you use, and verbose a boolean controlling the verbosity level. 
   
5. **Retrieval (and evaluation):** Retrieval is done the same way as in the original pipeline, by running the following line of code in Matlab:

        matches = RetrieveMatches(path/to/modality2/feature/data, bof, nr_retrievals);

   OBS! the path to your data shuld now point to the folder with the retrieved features, and not the folder with image data!
   
   To be able to evaulate the retrieval, your pairs of modality1 and modality2 images must have the same names. (For a given query, a retrieved image is considered a correct match if it has the same name as a query (up to a suffix).) If you wish to do evaluation, this is done by running 

        [correcttable, nrcorrect] = EvalMatches(matches, path/to/modality2/feature/data);
        
   Which returns a table *correcttable* of size *nr_queries X 1*, with each line containing one number, which tells at what place (among the first nr_retrievals) the correct match was found. If it wasn't, the number will be 0. And *nrcorrect* is the total number of the cases in which the correct match for the query was retrieved within the first *nr_retrievals*.

**Important:** for each script make sure you are in the right working directory to run it, and update the paths to load the correct
datasets and export the results in your desired directory.



## Citation
```
@article{DBLP:journals/corr/abs-2201-03597,
  author    = {Eva Breznik and
               Elisabeth Wetzer and
               Joakim Lindblad and
               Natasa Sladoje},
  title     = {Cross-Modality Sub-Image Retrieval using Contrastive Multimodal Image
               Representations},
  journal   = {CoRR},
  volume    = {abs/2201.03597},
  year      = {2022},
  url       = {https://arxiv.org/abs/2201.03597},
  eprinttype = {arXiv},
  eprint    = {2201.03597},
  timestamp = {Thu, 20 Jan 2022 14:21:35 +0100},
  biburl    = {https://dblp.org/rec/journals/corr/abs-2201-03597.bib},
  bibsource = {dblp computer science bibliography, https://dblp.org}
}
```
