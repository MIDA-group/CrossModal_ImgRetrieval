SHELL = /usr/bin/zsh
PP = PYTHONPATH="$(PYTHONPATH):."
IJFLAGS = --ij2 --headless --console --run compute_sift.py

###############################   SET PARAMETERS   ###########################################
CCPY = python3
CCM = matlab #octave #<--- need to (re)implement some of the matlab functions for it to work. Will do if necessary.

#SET VARIABLES:
#path to (folder of, inside data folder) images to build BOF from
# current_w_dir/data/MODALITY is the full path
MODALITY1 = mod1
#path to (folder of, inside data folder) images to query
MODALITY2 = mod2

#results folder: can be relative path
SAVE_FOLDER = results #/home/eva/Desktop/ImRetCode/CrossModal_ImgRetrieval/results


#which feature extraction to use:
FEATURE_EXTRACTOR = sift #sift #surf #resnet
#other parameters:
VOC = 2000 #size of vocabulary for bof
VOC_RERANK = 2000 #size of vocabulary for bofs in reranking step

HIT = 15 #how many first retrieved hits to check/report
HIT_AFTER_RERANK = 10 #how many first retrieved hits to check/report after reranking. 
#OBSERVE: reranking as implemented reranks ONLY the first "HIT" hits, as they were calculated by "retrieval"!

VERBOSE = false #control the level of details reported in the command line during execution


###### POTENTIALLY USEFUL
EVLT = true #whether or not to not only do retrieval but also evaluate its correctness. The problem: it 
#requires the corresponding pairs of images in mod1 and mod2 to have the exact same name!

###########################################################################################

#what all to do.
.PHONY: all features retrieval reranking #clean
all: features retrieval reranking  #add or remove reranking (and even features maybe) if needed
#what it all does:
#features: calcs features (csvs, resnet, or does nothing if surf)
#retrieval: build BOF, do retrieval, write results
#reranking: do reranking, write results
#clean: clean the created folders: for sift/resnet etc. does not however clean the results. 

############################################################################################
#strip dir vars to somewhat avoid user errors in var definition
FEAT_EXTR = $(strip $(FEATURE_EXTRACTOR))
MOD1 = $(strip $(MODALITY1))
MOD2 = $(strip $(MODALITY2))
SAVE_TO = $(strip $(SAVE_FOLDER))

ifeq ($(OS),Windows_NT) #assume 64 version atm
    FIJI = ./Fiji.app/ImageJ-win64.exe
	OQ = "
	IQ = '
else
    UNAME_S := $(shell uname -s)
    ifeq ($(UNAME_S),Linux)
		FIJI = ./Fiji.app/ImageJ-linux64
	else 
		FIJI = ./Fiji.app/ImageJ-macosx
	endif
	OQ = '
	IQ = "
endif
ifeq ($(strip $(CCM)),matlab)
	CC = matlab -batch
else #octave
	CC = octave --no-gui --braindead --eval
endif


#to force remake of existing features, first delete existing folders of features (or simply make clean). 
#if features target called, it only does anything (ie recalcs features) if the folder with features doesnt exist yet. 

data/%/features/sift: PARAMS = $(OQ)path=$(IQ)./data/$*/*$(IQ), 
data/%/features/sift: VRBS = verbose=$(IQ)$(VERBOSE)$(IQ)$(OQ)
data/%/features/sift: | data/% 
	rm -rf $@_tmp
	mkdir -p $@_tmp
	$(FIJI) $(IJFLAGS) $(PARAMS)$(VRBS)
	mv data/$*/*.csv data/$*/features/sift_tmp/.
	mv $@_tmp $@

data/%/features/resnet: | data/%
	rm -rf $@_tmp
	mkdir -p $@_tmp
	$(CCPY) resnet_features.py --data=data/$* --outpath=data/$*/features/resnet_tmp
	mv $@_tmp $@

data/%/features/surf:  | data/% #create parent folders here too, but only to serve as a dummy in case of SURF
	mkdir -p $@


$(SAVE_TO)/matches_for_$(MOD2)_in_$(MOD1)_$(FEAT_EXTR).csv:  data/$(MOD1)/features/$(FEAT_EXTR)  data/$(MOD2)/features/$(FEAT_EXTR)
	$(CC) "features='$(FEAT_EXTR)'; mod1='$(MOD1)'; mod2='$(MOD2)'; evlt=$(EVLT); save_to='$(SAVE_TO)'; saveit=true; vocab=$(VOC); hits=$(HIT); verbose=$(VERBOSE); main_script"


data/%/patches: UTILS = addpath('./utils/')
data/%/patches: READ_PAR =  'ReadVariableNames', true, 'ReadRowNames', true, 'Delimiter', ',', 'VariableNamingRule', 'preserve' 
data/%/patches: MATCHES = fullfile('$(SAVE_TO)', 'matches_for_$(MOD2)_in_$(MOD1)_$(FEAT_EXTR).csv')
data/%/patches: | data/% # cuts patches
	rm -rf $@_tmp
	mkdir -p $@_tmp
	$(CC) "$(UTILS); matchtable=readtable($(MATCHES), $(READ_PAR)); GeneratePatches(matchtable, 'data/$(MOD2)', 'data/$(MOD1)', verbose=$(VERBOSE), saveto='data/$*/patches_tmp');"
	mv $@_tmp $@


features: | data/$(MOD1)/features/$(FEAT_EXTR) data/$(MOD2)/features/$(FEAT_EXTR)

retrieval: | $(SAVE_TO)/matches_for_$(MOD2)_in_$(MOD1)_$(FEAT_EXTR).csv	

reranking: | $(SAVE_TO)/matches_for_$(MOD2)_in_$(MOD1)_$(FEAT_EXTR)_reranked.csv


$(SAVE_TO)/matches_for_$(MOD2)_in_$(MOD1)_$(FEAT_EXTR)_reranked.csv: data/$(MOD1)/patches/features/$(FEAT_EXTR)  $(SAVE_TO)/matches_for_$(MOD2)_in_$(MOD1)_$(FEAT_EXTR).csv
	$(CC) "features='$(FEAT_EXTR)'; mod1='$(MOD1)'; mod2='$(MOD2)'; evlt=$(EVLT); save_to='$(SAVE_TO)'; saveit=true; vocab=$(VOC_RERANK); hits=$(HIT_AFTER_RERANK); verbose=$(VERBOSE); rerank_script"



#clean: features retrieval # OBS: will clean all the created feature folders, not just the latest! And any cut patches from reranking
#	rm -rf data/$(MOD1)/features data/$(MOD2)/features data/$(MOD1)/patches


