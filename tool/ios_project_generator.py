import os
import shutil
import subprocess
from pathlib import Path

from cmake_utils import get_cmake_executable
from project_generator import ProjectGenerator


class IOSProjectGenerator(ProjectGenerator):
    def __init__(self):
        self.os = 'IOS'
        self.sub_directory = 'ios'

    def generate(self, source_directory: Path, build_directory: Path, profile: str, arch: str = None):
        self.arch = arch if arch else "arm64"
        ios_directory = Path(build_directory, f"{self.sub_directory}-{self.arch}")
        print(ios_directory)
        if not ios_directory.exists():
            self.clone_project(ios_directory)

        cmake_tool_chain_path = Path(source_directory, 'cmake', 'utils', 'ios.toolchain.cmake')

        args = [get_cmake_executable(), str(source_directory), '-B%s' % str(Path(build_directory, f'ios-{self.arch}'))]

        args += self.get_cmake_args(cmake_tool_chain_path, ios_directory, profile)
        command = ' '.join(args)
        print(f"{self.os}-{self.arch} generate command: {command}")
        exit_code = subprocess.call(command, shell=True, cwd=str(source_directory))
        if exit_code != 0:
            command = ' '.join(args)
            raise Exception(f"{self.sub_directory} generate failed: {exit_code}, command is: {command}" )

    def get_cmake_args(self, cmake_tool_chain_path: Path, ios_directory: Path, profile: str = 'Release'):
        return ['-DPLATFORM=OS64', '-DBUILD_DIR=%s' % str(ios_directory),
                '-DCMAKE_BUILD_TYPE=%s' % profile,
                '-DCMAKE_TOOLCHAIN_FILE=%s' % str(cmake_tool_chain_path), '-DENABLE_BITCODE=FALSE', '-GXcode',
                '-DOS=%s' % self.os
                ]

    def clone_project(self, ios_directory):
        current_path = os.path.abspath(os.path.join(os.path.realpath(__file__), '..'))
        print("ios clone",str(Path(current_path, self.sub_directory)), str(ios_directory))
        shutil.copytree(str(Path(current_path, self.sub_directory)), str(ios_directory))
