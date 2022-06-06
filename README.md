This project is part of a workflow that labels and analyzed videos of a single rat being stimulated wirelessly through its muscles and spinal electrodes. The codes are used to analyze and plot video data labeled by DeepLabCut (DLC). For documentation and clarification purposes, this README will attempt to explain the entire workflow starting from after collecting the video data to generating the plots.
1. DeepLabCut
   1. Creating a new DLC project
      1. A new project is created from the template using the DLC's GUI
      2. Modify the template "config.yaml" as follow:
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
         1. If the training machine is different from the machine creating the config file, change the "project_path" to the appropriate path on the training machine.
         2. If this is the first time the model is being trained, keep the "init_weight" as default or change it to an appropriate path on the training machine.
            1. If this model is being continuously trained based on a previously trained model, the "init_weight" should be the directory on the training machine to the previous model.
         3. Lastly, if the model is anticipated to be trained beyond the inital 1030000 iterations, make sure the "multi-step" section is appropriately updated to reflect that. Typically, the learning rate beyond the 1030000 iterations is set at 0.001 and is added 1000000 iterations on top of the latest iteration value.
   4. Train the model
      1. The models used in this project are trained using Google Colab notebook with T100 GPU.
      2. The project itself is stored in a Google Drive folder. Before each training session, the Colab notebook is linked to the Drive, so the notebook can read and write data to and from Drive's folders.
      3. The model is trained until the loss values are consistently below 0.015
   5. Label the videos
      1. Once the model's loss reached the desired value, the training is stopped (loss ~= 0.01)
      2. The latest model is then used to label the remaining videos. The csv files containing the coordinates of the labeled landmarks are exported. 
      3. The labeled videos are then inspected by the researchers.
   6. Check the quality of the labeled videos and re-train the model
      1. From a cluster of videos with similar settings and lighting conditions, in a randomly chosen labeled video, if the tracklets (labeled landmarks) have a low p-score, how confident the model is, and the labeled points themselves are moving around violently even when there is no movement, the video is added to the DLC GUI list for extracting outliners to be re-labeled.
         1. Otherwise, if the labeled videos are good, move on to step 2 in MATLAB.
      2. DLC extracts 20 frames (default value) from the labeled videos using the k-means algorithm for the researchers to check and correct if necessary.
      3. The extracted frames will have their labels corrected by the researchers. 
      4. Once done, the newly added and label-corrected frames are added to the current dataset.
      5. Repeat steps 1.3 to here again until all the videos are correctly labeled.
      6. After the csv and the labeled videos are generated using the latest model, the previously generated csv and videos are deleted.  
2. MATLAB
   1. Organize and load the labeled data
      1. The experimental parameters are stored directly in the name of the videos, correspondently, the name of their csv files.
      2. MATLAB generates a list of csv files to be loaded and analyzed.
         1. Since there are possibilities that other types of csv are also presented in the folder, the regular expression(regex) method is used to ensure that only the csv files containing date information in their names are considered.
      3. Similarly, using regex, other experimental parameters are also extracted from the file names including the date of the experiment, the stimulation channel, the amplitude, the frequency, and the pulse width.
         1. In cases where any of the experimental parameters are not available (except for date), the value of -1 is used instead
   2. Tracklets data
      1. When the experimental parameters are extracted, we start to import the tracklets coordinates from the csv files.
      2. The tracklets are filtered by p-score = 0.7, which is 70% or more confidence in the labeling results.
      3. The data is then stored in a MATLAB struct.
         1. Each row represents one frame.
         2. Each column in a row is the coordinates of the body parts as well as the p-score.
         3. The coordinate is x, y for 2D data and x, y, and z for 3D data.
         4. The first column is the frame number.
            1.   With a known frame rate, which is 200fps, this can be used to represent the time.
         5. Once all the raw data is loaded from the csv, we calculate the angles as well as the displacement of the tracklets
   3. Calculate the angle and displacement
      1. Angle data
         1. There are 4 types of angles calculated. Here are how each type is calculated:
            1. Hip angle: pelvis top, hip, knee
            2. Knee angle: hip, knee, ankle
            3. Ankle angle: knee, ankle, MTP
            4. Lower limb angle: pelvis top, hip, MTP
         2. To calculate the angles, the vector from the middle point to the other points are obtained.
            1. The angle is then calculated using one of the two following ways:
               1. In most cases, the angle is the arctangent of the magnitude of the cross product over the dot product of the vectors.
               2. In some cases where gimble lock happens, the MATLAB function "subspace" is used instead.   
            2. The calculated data is then stored in a MATLAB struct object that contains all the angle values for each type of angle, their timestamp (frame number), and their original coordinates.
      2. Displacement data
            1. The displacement data of the experiment is calculated with the following assumptions:
               1. The differences in positions of a given body part at the start of the recorded video (the 1st frame of the video) and when the stimulation is applied are negligible.
               2. The displacement only happens in a 2D plane, and the movement in the perpendicular direction to the video's plane is negligible.
               3. A ruler is put near the experimental site to obtain the number of pixels per cm of the experiment, assuming that the distance between the ruler and the displacement plane is very small compared to the distance between the plane and the camera.
            2. Obtaining the pixels to cm ratio:
               1. When the videos are recorded, a ruler is placed nearby.
               2. For each of the videos, their first frames are extracted and saved.
               3. Using ImageJ, measure the number of pixels within a known distance in the ruler, which, in most cases, is about 5 inches, to obtain the pixels/cm value.
               4. The value is then stored in the video-data.csv for the corresponding video and is loaded when the MATLAB code runs.
            3.  Measuring the displacement
               1. Based on the above assumptions, the displacement is calculated as the distance between the first frame and each of the subsequent frames for each of the body parts. The calculated values are in pixels
               2. The calculated values are then converted to cm using the measured resolution for each of the videos.
               3. The final values are then stored as the displacement of each of the body parts in each of the frames compared to its position in the 1st frame.
               4. The maximum displacement value is also obtained and stored in a struct object
   4. Save the data
      1. If no error arises, the raw and calculated data will then be saved
      2. The raw data as well as the calculated data are transferred to a single struct object.
      3. The object is organized so that each row contains all the experimental parameters, the raw data object, the calculated displacement data object, and the angle data object.
      4. The object is then saved to the computer for further analysis and plotting.
   
   5. Plot the data
      1. To plot the data, the corresponding data object is first loaded into the workspace.
      2. Based on the type of desired plots, the data object is then filtered and organized to retrieve the data.
      3. In most cases, the x-axis is the amplitude of stimulation. Its unit is ADC. The values are then converted to mA as follows:
         1. Lookup table: the ADC value is converted to AMP (mA) using a provided lookup table. The table is loaded when the script initially runs.
         2. Linear function: the function y = 0.0127*x + 0.0069 is used where x is the ADC value, y is the AMP (mA) value.
      4. Plot the stimulation motion using skeleton:
         1. The plot is generated with the following assumption:
            1. The duration of stimulation in the experiment is very short. After reaching maximum displacement, the chosen body part quickly returns to the resting position.
         2. Since the framerate is 200 fps, it would be unreasonable to draw every frame from rest to peak. Instead, the data is downsampled to a chosen number of frames.
         3. Once the number of frames is decided, from the maximum displacement position, the frames are selected with equal time-step until enough frames are selected. 
         4. For each of the frames, the skeleton is generated by drawing lines between body parts using their coordinates in the correct order.
         5. The skeletons are then stacked on top of each other.
