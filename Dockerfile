FROM ubuntu:22.04

SHELL ["/bin/bash", "-c"]
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
    curl gnupg lsb-release software-properties-common sudo \
    build-essential git \
    python3-pip \
    libceres-dev libeigen3-dev \
    libpcl-dev \
    nlohmann-json3-dev \
    libusb-1.0-0-dev \
    tmux \
    && rm -rf /var/lib/apt/lists/*


RUN curl -sSL https://raw.githubusercontent.com/ros/rosdistro/master/ros.key \
    | gpg --dearmor -o /usr/share/keyrings/ros-archive-keyring.gpg

RUN echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/ros-archive-keyring.gpg] \
    http://packages.ros.org/ros2/ubuntu $(lsb_release -cs) main" \
    > /etc/apt/sources.list.d/ros2.list

RUN apt-get update && apt-get install -y --no-install-recommends \
    ros-humble-desktop \
    python3-rosdep \
    && rm -rf /var/lib/apt/lists/*

RUN python3 -m pip install --no-cache-dir colcon-common-extensions

RUN python3 -m pip install "rosbags==0.10.5"

WORKDIR /ros2_ws

COPY ./src ./src

# RESPLE's NTU config is reused for the Bunker DVI dataset (Livox Mid-360,
# lidar-only mode). Adapt it to the sensor:
#  - lidar_type HAP360: the bag's /livox/lidar is livox_ros_driver2/msg/CustomMsg,
#    and only the HAP360 lidar type subscribes to that message. With Mid70Avia
#    RESPLE subscribes to livox_ros_driver/msg/CustomMsg, never receives a scan
#    and records an empty trajectory.
#  - scan_line 4: the Mid-360 reports laser lines 0-3 and RESPLE keeps only
#    points with line < scan_line, so 1 would discard three quarters of each scan.
# The grep checks fail the build if the upstream config stops matching.
RUN CFG=src/RESPLE/resple/config/config_ntu_day_01.yaml && \
    sed -i \
      -e 's|topic_imu: /vn100/imu|topic_imu: /livox/imu|' \
      -e 's|lidar_type: Mid70Avia|lidar_type: HAP360|' \
      -e 's|scan_line: 1$|scan_line: 4|' \
      "$CFG" && \
    grep -q 'lidar_type: HAP360' "$CFG" && \
    grep -q 'scan_line: 4$' "$CFG"

RUN source /opt/ros/humble/setup.bash && \
    colcon build --cmake-args -DCMAKE_POLICY_VERSION_MINIMUM=3.5

ARG UID=1000
ARG GID=1000
RUN groupadd -g $GID ros && \
    useradd -m -u $UID -g $GID -s /bin/bash ros
    
WORKDIR /ros2_ws

RUN echo "source /opt/ros/humble/setup.bash" >> ~/.bashrc && \
    echo "source /ros2_ws/install/setup.bash" >> ~/.bashrc

CMD ["bash"]
