# Agent Instructions for Flutter Project

This document provides instructions for setting up and running this Flutter project in a clean Linux environment, specifically tailored for agents like Jules.

## Environment Setup for Linux (Jules)

**Important:** These instructions are intended for a Linux environment where Flutter is not pre-installed. Agents operating on Windows or attempting to run the Android application should not follow this guide.

The following script will set up the necessary environment, install the correct Flutter SDK, and run the application as a web app.

### Setup and Run Script

The `setup_and_run.sh` script is designed to automate the entire process. To execute it, run the following command in your terminal:

```bash
bash setup_and_run.sh
```

### Manual Setup Steps (for reference)

The script performs the following actions:

1.  **Install System Dependencies:** It installs essential packages required for Flutter development on Linux, including `wget`, `unzip`, `curl`, `git`, and the necessary libraries for web development.
2.  **Install Flutter SDK:** It downloads and installs the specific version of the Flutter SDK required for this project (3.35.0).
3.  **Configure PATH:** It adds the Flutter bin directory to the system's PATH to make the `flutter` command available.
4.  **Fetch Dependencies:** It runs `flutter pub get` to download the project's dependencies.
5.  **Run Tests:** It executes `dart test` to ensure the application's logic is correct.
6.  **Launch Web App:** It runs the application as a web app using `flutter run -d chrome`.
