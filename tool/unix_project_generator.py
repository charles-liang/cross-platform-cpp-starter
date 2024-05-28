import subprocess
from pathlib import Path

from cmake_utils import get_cmake_executable
from project_generator import ProjectGenerator


class UnixProjectGenerator(ProjectGenerator):
    def generate(self, source_directory: Path, build_directory: Path, profile: str):
        args = [get_cmake_executable(), str(source_directory),
                '-DCMAKE_BUILD_TYPE=%s' % profile, '-B%s' % str(Path(build_directory, 'linux'))]

        args += self.get_cmake_args()

        command = " ".join(args)
        print(f"linux generate cmake command: {command}")
        exit_code = subprocess.call(command, shell=True, cwd=str(source_directory))
        if exit_code != 0:
            raise Exception(f"linux generate cmake failed: {exit_code}, command is: {command}")

    def get_cmake_args(self):
        return ['-DCMAKE_CXX_COMPILER_WORKS=TRUE', '-G', '"CodeBlocks - Unix Makefiles"']
