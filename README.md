# ProjectScriptBash

ProjectScriptBash is a comprehensive project entirely written in Shell script. It aims to provide useful scripts for various needs, including process monitoring and anomaly detection.

## Table of Contents
- [Introduction](#introduction)
- [Features](#features)
- [Installation](#installation)
- [Usage](#usage)

## Introduction

ProjectScriptBash offers a collection of scripts designed to streamline various tasks in a Unix-like environment. The project's primary focus is on process monitoring and anomaly detection, making it a valuable tool for system administrators and developers.

## Features

- **Process Monitoring:** Continuously monitors system processes and logs their state.
- **Anomaly Detection:** Detects anomalies such as high CPU usage and allows automatic or manual handling of these anomalies.
- **Logging:** Saves logs of processes and anomalies for further analysis.

## Installation

To install and use this project, follow these steps:

1. Clone the repository:
    ```bash
    git clone https://github.com/MPSBeats/ProjectScriptBash.git
    cd ProjectScriptBash
    ```

2. Ensure that all scripts have execution permissions:
    ```bash
    chmod +x *.sh
    ```

## Usage

### Process Monitoring and Anomaly Detection

The main script, `scanner.sh`, monitors system processes and detects anomalies such as high CPU usage. Here is how to use it:

1. Run the script:
    ```bash
    ./scanner.sh
    ```

2. Follow the prompts to enter the interval time for process state saving (in seconds).

3. The script will log process states to `journalEtatProcessus.txt` and detect anomalies based on CPU usage.

4. If an anomaly is detected, the script provides options to kill the process, lower its priority, or ignore it.

### Example Usage

- **Start Monitoring:**
    ```bash
    ./scanner.sh
    ```

- **Handle Anomalies:**
    - Choose to kill the process, lower its priority, or ignore it when prompted.

