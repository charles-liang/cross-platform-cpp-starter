import os
import platform
import shutil
import subprocess
from pathlib import Path

from cmake_utils import get_cmake_executable
from project_generator import ProjectGenerator


class MacOSProjectGenerator(ProjectGenerator):
    def __init__(self):
        self.os = 'MacOS'
        self.sub_directory = self.os.lower()

    def generate(self, source_directory: Path, build_directory: Path, profile: str = 'Release', arch: str = ''):
        self.arch = arch if arch else platform.machine()
        print(f"Generating {self.os} project for {self.arch} arch")
        macos_directory = Path(build_directory, self.sub_directory)
        if not macos_directory.exists():
            self.clone_project(macos_directory)

        cmake_tool_chain_path = Path(source_directory, 'cmake', 'utils', 'ios.toolchain.cmake')

        args = [get_cmake_executable(), str(source_directory), '-B%s' % str(Path(build_directory, self.sub_directory))]

        args += self.get_cmake_args(cmake_tool_chain_path, macos_directory, profile, self.arch)
        command = " ".join(args)
        print(f"{self.os} generate cmake command: {command}")
        exit_code = subprocess.call(command, shell=True, cwd=str(source_directory))
        if exit_code != 0:
            command = ' '.join(args)
            raise Exception(f"{self.os} generate failed: {exit_code}, command is: {command}" )

    def get_cmake_args(self, cmake_tool_chain_path: Path, macos_directory: Path, profile: str, arch: str):
        target_arch = 'MAC_ARM64' if arch == 'arm64' else 'MAC'
        return ['-DPLATFORM=%s' % target_arch, '-DCMAKE_BUILD_TYPE=%s' % profile,'-DBUILD_DIR=%s' % str(macos_directory), 
                '-DOS=%s' % self.os,
                '-DCMAKE_TOOLCHAIN_FILE=%s' % str(cmake_tool_chain_path), '-G Xcode']

    def clone_project(self, macos_directory):
        current_path = os.path.abspath(os.path.join(os.path.realpath(__file__), '..'))
        shutil.copytree(str(Path(current_path, self.sub_directory)), str(macos_directory))
