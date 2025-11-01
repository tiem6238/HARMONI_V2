import pickle
import torch
from torch.utils.data import DataLoader
from tqdm import tqdm
import warnings

def convert_pkl_to_pth(files, path):
    print("Converting the following files from pkl to pth: " + str(files) + "\n")
    for file in files:
        try:
            new_file = file.replace(".pkl", ".pth")
            print("Converting " + file + " to " + new_file + " ...")
            with open(path + "/" + file, "rb") as f:
                with warnings.catch_warnings():
                    print("File found! Proceeding with conversion..")
                    data = pickle.load(f, encoding='latin1') # latin1 ensures Python 2 compatibility
            torch.save(data, path + "/" + new_file)
            print("New file created: " + new_file)
        except FileNotFoundError:
            print("File not found! File provided: " + path + "/" + file)
            print("Skipping file...")
    print("Files can be found here: " + path)

def main():
    smpl_path = "data/body_models/smpl"
    smpla_path = "data/body_models"
    smplx_path = "data/body_models/smplx"

    smpl_files = ["SMPL_MALE.pkl", "SMPL_FEMALE.pkl", "SMPL_NEUTRAL.pkl"]
    smpla_files = ["SMPLA_MALE.pkl", "SMPLA_FEMALE.pkl", "SMPLA_NEUTRAL.pkl"]
    smplx_files = ["SMPLX_MALE.pkl", "SMPLX_FEMALE.pkl", "SMPLX_NEUTRAL.pkl"]

    smplDict = {
        smpl_path: smpl_files,
        smpla_path: smpla_files,
        smplx_path: smplx_files
    }

    for smplPath, smplFiles in smplDict.items():
        convert_pkl_to_pth(smplFiles, smplPath)

    print("\n*** DONE! ***\n")

if __name__ == "__main__":
    main()

