# hello-cross-platform

This repository is used to demonstrate how to build a cross-platform application with C/C++ & CMake


![Alt Text](https://thumbs.gfycat.com/ScholarlyOrneryDrongo-size_restricted.gif)


# Software requirement
Install python3, jinja2 https://pypi.org/project/Jinja2/
## MacOS/Linux
Install GCC, G++ and Clang/LLVM.
## Windows
Install Cygwin
https://www3.ntu.edu.sg/home/ehchua/programming/howto/Cygwin_HowTo.html

Make sure you have installed the gcc, g++, cmake packages and setup environment variable
## Android
Install Android SDK, NDK and CMake toolchain
https://developer.android.com/studio/projects/install-ndk
## iOS
Install Xcode

# Build project
## Windows:
 runner.bat build -platform windows
## MacOS: 
./runner build -platform osx
## Linux: 
./runner build -platform linux
## Android: 
./runner build -platform android
## iOS: 
./runner build -platform ios

Note: If you want to test iOS app on real device instead of simulator, you must sign exampleapp & helloworld framework

# Clean build
./runner build clean

# Project structure
## src/ directory
Containing shared code base for different platforms
## tool/ directory 
A small python script, used to compile applications for different platforms
## cmake/ directory
CMake utilities
