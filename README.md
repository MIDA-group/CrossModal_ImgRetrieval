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

## How does it work?

TODO

<p align="center">
  <img src="resources/pipeline.png" width=700 />
</p>

## Key findings of the paper
TODO

## Datasets
We used the following publicly available dataset:
* Multimodal Biomedical Dataset for Evaluating Registration Methods: https://zenodo.org/record/3874362

## Creation of CBIR
TODO

## Scripts
TODO

**Important:** for each script make sure you update the paths to load the correct
datasets and export the results in your favorite directory.

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
