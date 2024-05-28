import logging
import os
import subprocess
from pathlib import Path

from build_executor import BuildExecutor
from cmake_utils import get_cmake_executable


class UnixBuildExecutor(BuildExecutor):
    def __init__(self, source_directory: Path):
        self.source_directory = source_directory
        self.build_directory = Path(source_directory, 'build', 'linux')
        self.logger = logging.getLogger(__name__)

    def build(self, profile: str):
        target = 'helloworld'

        args = [get_cmake_executable(), '--build', str(self.build_directory), '--target', target,
                '--', '-j', '%d' % os.cpu_count()]
        command = " ".join(args)
        print(f"linux build cmake command: {command}")
        exit_code = subprocess.call(args, cwd=str(self.build_directory))
        if exit_code != 0:
            raise Exception(f"linux, build failed: {exit_code}, command is: {command}")

        self.logger.info('Build completed, output %s', Path(self.build_directory, target))
