# AlphaFold
## Python and Bash scripts that help preprocess and analyze the AlphaFold database for protein structure predictions
### Most of the scripts here depend on other scripts, so make sure you open each script to know what inputs and scripts are required for each step. A lot of the SLURM scripts are necessary because some jobs take roughly a day for 1million protein structures. You can reduce that by playing around with parallelization, assuming you have the resources.

### Steps for getting on your terminal to work with AlphaFold (do this after initial setup with the MCC):
- Get on your terminal (type cmd into the Windows search bar if you are unfamiliar)
- Type "ssh yourlinkblue@mcc.uky.edu" and hit enter, for example: "ssh jasm123@uky.edu"
  * This connects you to the campus virtual machine so your computer doesn't have to personally do millions of lines of code.
- Type "cd /scratch/yourlinkblue/" and hit enter. For example: "cd /scratch/jasm123/"
  * This changes your directory to your personal scratch directory. This is an organized space to hold the AlphaFold data.
- Type "source /home/yourlinkblue/.bashrc" and hit enter. Change 'yourlinkblue' with your linkblue, you know the drill.
- Type "conda activate py310" and hit enter.
  * This allows your terminal to run python3 commands, essential to doing most of the code execution for this project. 'py310' is just what I called my python3 download, if you don't have it downloaded yet you'll have to do a bunch of extra stuff to save a version of python3 to be used.
- Now you should be able to create an alpha-fold folder to store all your stuff in! Just type "mkdir alpha-fold" and hit enter to create the folder. Then type "cd alpha-fold" and hit enter to access that folder. Do all your work while in that folder.

### Steps for processing AlphaFold DB for analysis:
- Download pdb from AlphaFold DB using **[pdb-downloader.sh](./re-download/pdb-downloader.sh)** or Dr Shao's scripts **[shao-scripts](./shao-scripts)**.
  * To execute a .sh file, save the file (you can copy and paste the code into a notepad and then save as pdb-downloader.sh, and it should turn into a executable file). Then, in the terminal directory you want to execute the file in (probably in a designated alpha-fold directory), type "bash [FILE_NAME]" and click enter. In this case the command would be "bash pdb-downloader.sh". 
  * For v4 AF database, copy all the scripts in **[v4-data-download](./v4-data-download)** to a folder and follow these steps:
  * Download the v4_updated_accessions.txt from the AF website. To sample from the whole AF database, use accessions_id.csv.
  * Create batch1 csv: python3 **[select-samples.py](./v4-data-download/select-samples.py)** accessions_id.csv 1
  * Create batches 2-5: ./**[make-batches.sh](./v4-data-download/make-batches.sh)**
    * Note, the make-batches command uses accession_ids.csv versus accessions_id.csv which is used up until then. Should this be fixed to match?
    * Also, if a 'permission denied' error occurs, use use the command chmod u+x make-batches.sh first, then run ./make-batches.sh
  * Create download urls for each batch e.g. for batch1: python3 **[create-url-list.py](./v4-data-download/create-url-list.py)** batch1.csv url-batch1.csv
  * Download pdb files using urls e.g. for batch1: ./**[download-mcc.sh](./v4-data-download/download-mcc.sh)** url-batch1.csv
    * If 'permission denied error occurs, do the same command as above but replace make-batches.sh with download-mcc.sh
    * Also, this will flood your directory with pdb files. The process also might take a bit, let it run and don't stop it or you'll miss some data.
    * There's a lot of "failed: Cannot assign requested access. Retrying" errors... but I'm just going to let it keep doing it's thing.
    * This process typically takes around 30-40 minutes. Once it finishes running, you can enter the command: "ls -U | head -4". This will show the first 4 files in the directory, which should hopfully be pdb files (if you just type "ls" it will try to show millions of files, which will break things).
- Convert pdb to dssp/dat files using **[dssp-pdb2dat.sh](./re-download/dssp-pdb2dat.sh)** or Dr Shao's version **[shao-scripts](./shao-scripts)**.
  * In order to execute dssp-pdb2dat.sh properly (at least for windows), you need to install dssp-wsl and wsl. dssp-wsl can be installed by entering "pip install dssp-wsl" and wsl can be installed by entering "wsl--install". You'll propably have to restart your device after wsl is installed.
- Convert dssp/dat to out files using **[dat-to-out.py](./re-download/dat-to-out.py)** and **[submit-dat-to-out.sh](./re-download/submit-dat-to-out.sh)**.
- Use the scripts here **[dat-and-csv-generation](./dat-and-csv-generation)** for residue and secondary structure (ss) analysis:
  * Residues are stored in dat files e.g. ALA.dat or VAL.dat. To generate them, use **[submit-res_out_2_dat_v2.sh](./dat-and-csv-generation/submit-res_out_2_dat_v2.sh)** and **[res_out_2_dat_v2.sh](./dat-and-csv-generation/res_out_2_dat_v2.sh)** to extract residue, PLDDT and ss info from the out files in the directory:
  * SS are stored in csv files e.g. coil.csv or turn.csv. To get the secondary structure info, use **[submit-ss_out_2_csv_v2.sh](./dat-and-csv-generation/submit-ss_out_2_csv_v2.sh)** and **[ss_out_2_csv_v2.sh](./dat-and-csv-generation/ss_out_2_csv_v2.sh)** to extract residue, PLDDT and ss info from the out files in the directory.

- To segregate by number of residues in proteins, use the scripts here: **[ss-number](./ss-number)** (secondary structures) and **[res-number](./res-number)** (residues):
  * For residues, make a folder (e.g. res-number) for residues, and use **[submit_res-merger.sh](./res-number/submit_res-merger.sh)** and **[res-merger.sh](./res-number/res-merger.sh)** to classify the residues in 0-10 folders. 
  * Use **[run-datmerger.sh](./res-number/run-datmerger.sh)** and **[dat-merger.sh](./res-number/dat-merger.sh)** to merge all the dat files under each length classification.
  * For secondary structures, make a folder (e.g. ss-number) for residues, and use **[submit_ss-merger.sh](./ss-number/submit_ss-merger.sh)**  and **[ss-merger.sh](./ss-number/ss-merger.sh)** within the folder. 
  * Use **[run-csvmerger.sh](./ss-number/run-csvmerger.sh)** and **[csv-merger.sh](./ss-number/csv-merger.sh)** to merge all the csv files under each length classification.
- Generate boxplot files to be processed by our notebooks:
  * For residues, use **[run-stat-res-finder_10_90.sh](./res-number/run-stat-res-finder_10_90.sh)**, **[stat-res_10_90-finder.sh](./res-number/stat-res_10_90-finder.sh)** and **[stat-res_10_90-finder.py](./res-number/stat-res_10_90-finder.py)** in the **[res-number](./res-number)** folder that contains the 0-10 folders for residues.
  * For secondary structures, use **[run-stat-ss-finder_10_90.sh](./ss-number/run-stat-ss-finder_10_90.sh)**, **[stat-ss_10_90-finder.sh](./ss-number/stat-ss_10_90-finder.sh)** and **[stat-ss_10_90-finder.py](./ss-number/stat-ss_10_90-finder.py)**  in the **[ss-number](./ss-number)** folder that contains the 0-10 folders for secondary structures.
  * For all the dat and csv files (not segregated by length). Use **[submit-ss_total.sh](./ss-number/submit-ss_total.sh)** and **[submit-res_total.sh](./res-number/submit-res_total.sh)** to generate to generate a total_*csv and total_*dat files, and a *.boxplot file for the whole batch.
