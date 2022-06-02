This project is part of a workflow that labels and analyzed videos of a single rat being stimulated wirelessly through its muscles and spinal electrodes. The codes are used to analyze and plot video data labeled by DeepLabCut (DLC). For documentation and clarification purposes, this README will attempt to explain the entire workflow starting from after collecting the video data to generating the plots.
1. DeepLabCut
   1. Creating a new DLC project
      1. A new project is created from the template using the DLC's GUI
      2. Modify the template config.yaml as follow:
         1. Add the following body parts to "bodyparts" section: pelvis top, hip, pelvis bottom, knee, ankle, MTP, and toe.
         2. Change the "dotsize" value to 5.
         3. The "default_net_type" is resnet_101.
         4. Other parameters are kept as default values.
   2. Add hand-labeled data
      1. After creating the project, select a couple of videos using the DLC GUI to start extracting frames. 
      2. Use the default method, "k-means clustering", to select 20 frames (default value) from each of the videos.
      3. The extracted frames are saved automatically by DLC into the "labeled-data" folder in the DLC folder. The folder is further organized by videos.
      4. Using the DLC GUI, open each of the folders and start labeling each frame with the locations of the body parts as specified in step 1.1.2.1.
         1. If the body part is not visible, do not label it.
         2. The body part's dot is placed as precisely as possible on top of the actual marker on the animal's body.
      5. Once all the frames are labeled, save the labels and move on to the next un-labeled videos.
   3. Create training dataset
      1. Once all the extracted frames are labeled, create a new training dataset using DLC GUI. 
      2. From the model selection, select "resnet_101".
      3. Other options are kept as default.
      4. After creating a new training dataset, a new folder in the "dlc-models" is created. 
      5. Navigate to the latest iteration folder to modify the model config file.
      6. In the current iteration folder, navigate to the "train" folder and modify the "pose_cfg.yaml" as follow:
         1. 
   4. Train the model
   5. Label the videos
   6. Check the quality of the labeled videos
2. MATLAB
   1. Organize and load the labeled data
   2. Plot the data
