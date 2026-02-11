# [RESPLE](https://github.com/ASIG-X/RESPLE) converter to [HDMapping](https://github.com/MapsHD/HDMapping)

## Hint

Please change branch to [Bunker-DVI-Dataset-reg-1](https://github.com/MapsHD/benchmark-RESPLE-to-HDMapping/tree/Bunker-DVI-Dataset-reg-1) for quick experiment.  

## Example Dataset: 

Download the dataset from [Bunker DVI Dataset](https://charleshamesse.github.io/bunker-dvi-dataset/)  

## Dependencies

```shell
sudo apt install -y nlohmann-json3-dev
```

## Intended use 

This small toolset allows to integrate SLAM solution provided by [resple](https://github.com/ASIG-X/RESPLE) with [HDMapping](https://github.com/MapsHD/HDMapping).
This repository contains ROS 2 workspace that :
  - submodule to tested revision of RESPLE
  - a converter that listens to topics advertised from odometry node and save data in format compatible with HDMapping.

## Building

Clone the repo
```shell
mkdir -p /test_ws/src
cd /test_ws/src
git clone https://github.com/marcinmatecki/resple-to-hdmapping.git --recursive
cd ..
colcon build
```

## Usage - data SLAM:

Prepare recorded bag with estimated odometry:

In first terminal record bag:
```shell
ros2 bag record /current_scan /odometry
```

and start odometry:
```shell 
cd /test_ws/
source ./install/setup.sh # adjust to used shell
ros2 launch resple resple_eee_02.launch.py
ros2 bag play 
```

## Usage - conversion:

```shell
cd /test_ws/
source ./install/setup.sh # adjust to used shell
ros2 run resple-to-hdmapping listener <recorded_bag> <output_dir>
```

## Convert(If it's a ROS1 .bag file):

```shell
rosbags-convert --src {your_downloaded_bag} --dst {desired_destination_for_the_converted_bag}
```

## Record the bag file:

```shell
ros2 bag record /current_scan /odometry -o {your_directory_for_the_recorded_bag}
```

## RESPLE Launch:

```shell
cd /test_ws/
source ./install/setup.sh # adjust to used shell
ros2 launch resple resple_eee_02.launch.py
ros2 bag play {path_to_bag}
```

## During the record (if you want to stop recording earlier) / after finishing the bag:

```shell
In the terminal where the ros record is, interrupt the recording by CTRL+C
Do it also in ros launch terminal by CTRL+C.
```

## Usage - Conversion (ROS bag to HDMapping, after recording stops):

```shell
cd /test_ws/
source ./install/setup.sh # adjust to used shell
ros2 run resple-to-hdmapping listener <recorded_bag> <output_dir>
```