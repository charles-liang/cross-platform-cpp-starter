import os
import shutil
import subprocess
from pathlib import Path

from cmake_utils import get_cmake_executable
from project_generator import ProjectGenerator


class MacOSProjectGenerator(ProjectGenerator):
    def __init__(self):
        self.platform = 'macos'
        self.sub_directory = self.platform

    def generate(self, source_directory: Path, build_directory: Path, profile: str):
        macos_directory = Path(build_directory, self.sub_directory)
        if macos_directory.exists():
            return
        self.clone_project(macos_directory)

        cmake_tool_chain_path = Path(source_directory, 'cmake', 'utils', 'ios.toolchain.cmake')

        args = [get_cmake_executable(), str(source_directory), '-B%s' % str(Path(build_directory, self.sub_directory))]

        args += self.get_cmake_args(cmake_tool_chain_path, macos_directory)
        command = " ".join(args)
        exit_code = subprocess.call(command, shell=True, cwd=str(source_directory))
        print(f"{self.platform} generate cmake command: {command}")
        if exit_code != 0:
            command = ' '.join(args)
            raise Exception(f"{self.platform} generate failed: {exit_code}, command is: {command}" )

    def get_cmake_args(self, cmake_tool_chain_path: Path, macos_directory: Path):
        return ['-DPLATFORM=MAC_UNIVERSAL', '-DBUILD_DIR=%s' % str(macos_directory),
                # '-SDK_VERSION', ''
                '-DCMAKE_TOOLCHAIN_FILE=%s' % str(cmake_tool_chain_path), '-GXcode']

    def clone_project(self, macos_directory):
        current_path = os.path.abspath(os.path.join(os.path.realpath(__file__), '..'))
        shutil.copytree(str(Path(current_path, self.sub_directory)), str(macos_directory))
