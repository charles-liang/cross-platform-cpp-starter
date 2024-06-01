import subprocess
from pathlib import Path

from cmake_utils import get_cmake_executable
from path_utils import get_cygwin_path
from project_generator import ProjectGenerator


class WinProjectGenerator(ProjectGenerator):
    def __init__(self):
        self.os = 'win'
        
    def generate(self, source_directory: Path, build_directory: Path, profile: str, arch: str = None):
        triple =  f'{self.os}-{profile}-{arch}'.lower()
        path = Path(build_directory, triple)
        args = [f'"{get_cmake_executable()}"', 
                '-DOS=%s' % self.os,
                '-DARCHS=%s' % arch,
                '-DCMAKE_BUILD_TYPE=%s' % profile,  f'-B{path}']

        args += self.get_cmake_args(profile)
        exit_code = subprocess.call(" ".join(args), shell=True, cwd=str(source_directory))
        if exit_code != 0:
            raise Exception("%s" % args)
        
    def get_cmake_args(self, profile: str = 'Release'):
        return ['-DCMAKE_CXX_COMPILER_WORKS=TRUE', '-DCMAKE_BUILD_TYPE=%s' % profile]
