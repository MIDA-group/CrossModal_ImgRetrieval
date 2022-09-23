import torch
import torch.nn as nn
import torchvision.models as models
from torchvision.transforms import Normalize, Compose
from torch.autograd import Variable
from pathlib import Path
import numpy as np
import pandas as pd
from PIL import Image
from tqdm import tqdm
import argparse

def main(args):
    resnet152 = models.resnet152(pretrained=True)

    modules=list(resnet152.children())[:-2]
    network = nn.Sequential(*modules)
    for p in network.parameters():
        p.requires_grad = False
    #add adaptive avgpooling, to make sure features always the same size, let's say 8x8 (=64 when flattened)
    final_layer = nn.AdaptiveAvgPool2d((8,8))



    # FEATURE EXTRACTION FOR OUR DATA
    datafolder = Path(args.data)
    images = [x for x in datafolder.glob('*') if x.is_file()]
    #should be supported by PIL: PPM, PNG, JPEG, GIF, TIFF and BMP. 
    #TODO: check if supported format, else raise not implemented
    #quick fix:
    try:
        tmp = Image.open(images[0])
    except:
        raise f"Error: not implemented (for files of type {images[0].suffix})"

    preprocess = Compose([
        lambda g: torch.from_numpy(g).float()/255.,
        #artificially create a 3chan. img:
        lambda img: torch.stack([img, img, img], axis=0) if img.ndim<3 else img.permute(2,0,1),
        lambda t: torch.unsqueeze(t, 0),
        Normalize(mean=[0.485, 0.456, 0.406],
                std=[0.229, 0.224, 0.225])
        ])

    network.eval()
    outpath = Path(args.outpath)
    outpath.mkdir(parents=True, exist_ok=True)

    print(f"\n------------------------------------\nCalculating RESNET features on {datafolder.name}...")
    
    for fil in tqdm(images, total=len(images)):
        name = Path(outpath, fil.with_suffix('.csv').name)
        img = np.array(Image.open(fil))
      
        #normalize and put into tensor as required by resnet :
        img = preprocess(img)

        img_var = Variable(img) # assign it to a variable
        features_var = final_layer(network(img_var)) # get the output from the last hidden layer of the pretrained resnet
        features = features_var.view(2048, 64).data # get the tensor out of the variable
    
        #now save features in csv
        out = pd.DataFrame(features.numpy())
        out.to_csv(name, header=None, index=False)
    print("DONE.\n")


def get_args() -> argparse.Namespace:
        parser = argparse.ArgumentParser(description='Data processing')
        parser.add_argument('--data', type=str, required=True, help="""Folder containing images we wish to calculate
                                                    the features on. Assumed to reside inside the provided folder _data_.""") #folder of images to calc features on, in "data"
        parser.add_argument("--outpath", type=str, default="data/features", help="""Folder to save resulting feature csvs to.""") #folder  to save resulting features to. (relative path)
        parser.add_argument("--verbose", action='store_true') #in case we wish to avoid verbosity. But there's little of it, so not in use atm

        args = parser.parse_args()

        return args


if __name__ == '__main__':
        main(get_args())