import os
import platform
import shutil
import subprocess
from pathlib import Path

from cmake_utils import get_cmake_executable
from project_generator import ProjectGenerator


class MacOSProjectGenerator(ProjectGenerator):
    def __init__(self):
        self.platform = 'macos'
        self.sub_directory = f"{self.platform}"

    def generate(self, source_directory: Path, build_directory: Path, profile: str, target: str = None):
        self.arch = target if target else platform.machine()
        print(f"Generating {self.platform} project {self.arch} for {profile} profile")
        print(f"source_directory: {source_directory}")
        to_directory = Path(source_directory,"build",f"{self.sub_directory}-{self.arch}")
        if not to_directory.exists():
            self.clone_project(self.platform, to_directory)

        cmake_tool_chain_path = Path(source_directory, 'cmake', 'utils', 'ios.toolchain.cmake')

        args = [get_cmake_executable(), str(source_directory), '-B%s' % str(Path(build_directory, f"{self.sub_directory}-{self.arch}")),]

        args += self.get_cmake_args(cmake_tool_chain_path, to_directory,profile,self.arch)
        command = " ".join(args)
        print(f"{self.platform} generate cmake command: {command}")
        exit_code = subprocess.call(command, shell=True, cwd=str(source_directory))
        if exit_code != 0:
            command = ' '.join(args)
            raise Exception(f"{self.platform} generate failed: {exit_code}, command is: {command}" )

    def get_cmake_args(self, cmake_tool_chain_path: Path, macos_directory: Path, profile: str = 'Release', arch: str = ''):
        target_arch = 'MAC' if arch == 'x86_64' else 'MAC_ARM64'
        #TODO: Because of cmake only support compile library one architecture at a time, so we need to generate two project for x86_64 and arm64
        return ['-DPLATFORM=%s' % target_arch, '-DBUILD_DIR=%s' % macos_directory,
                '-DCMAKE_BUILD_TYPE=%s' % profile, '-DCMAKE_SYSTEM_PROCESSOR=%s' % arch,
                '-DCMAKE_TOOLCHAIN_FILE=%s' % str(cmake_tool_chain_path), '-GXcode']

    def clone_project(self, from_directory: Path, to_directory: Path):
        current_path = os.path.abspath(os.path.join(os.path.realpath(__file__), '..'))
        shutil.copytree(str(Path(current_path, from_directory)),to_directory)
