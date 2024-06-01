import subprocess
from pathlib import Path

from cmake_utils import get_cmake_executable
from path_utils import get_cygwin_path
from project_generator import ProjectGenerator


class WinProjectGenerator(ProjectGenerator):
    def __init__(self):
        self.os = 'win'
        
    def generate(self, source_directory: Path, build_directory: Path, profile: str, arch: str = None):
        args = [get_cmake_executable(), 
                '-DOS=%s' % self.os,
                '-DCMAKE_BUILD_TYPE=%s' % profile, '-B%s' % get_cygwin_path(Path(build_directory, 'unix'))]

        args += self.get_cmake_args(profile)
        exit_code = subprocess.call(" ".join(args), shell=True, cwd=str(source_directory))
        if exit_code != 0:
            raise Exception("%s" % args)
        
    def get_cmake_args(self, profile: str = 'Release'):
        return ['-DCMAKE_CXX_COMPILER_WORKS=TRUE', '-DCMAKE_BUILD_TYPE=%s' % profile]
