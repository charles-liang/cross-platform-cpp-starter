import logging
import os
import subprocess
from pathlib import Path

from build_executor import BuildExecutor
from cmake_utils import get_cmake_executable
from path_utils import get_cygwin_path


class WinBuildExecutor(BuildExecutor):
    def __init__(self, source_directory: Path):
        self.os = 'win'
        self.source_directory = source_directory
        self.logger = logging.getLogger(__name__)

    def build(self, platform: str, source_directory: Path, build_directory: Path, profile: str, arch: str):
        target = 'helloworld'
        triple =  f'{self.os}-{profile}-{arch}'.lower()

        self.build_directory = Path(source_directory, 'build', f'{triple}')


        args = [get_cmake_executable(),
            '--build',f'{self.build_directory}', 
            '--target', target,
            '--config', profile,
                '--', '/m:%d' % os.cpu_count()]
        command = ' '.join(args)
        print(f"{self.os} build {command}")
        exit_code = subprocess.call(command, cwd=self.build_directory)
        if exit_code != 0:
            raise Exception("%s" % args)

        self.logger.info('Build completed, output %s', Path(self.build_directory, '%s.exe' % target))
