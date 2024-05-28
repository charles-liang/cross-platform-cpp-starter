import logging
import os
import subprocess
from pathlib import Path

from build_executor import BuildExecutor
from cmake_utils import get_cmake_executable


class MacOSBuildExecutor(BuildExecutor):
    def __init__(self, source_directory: Path):
        self.platform = 'macos'
        self.source_directory = source_directory
        self.build_directory = Path(source_directory, 'build', self.platform)
        self.logger = logging.getLogger(__name__)

    def build(self, profile: str):
        args = [get_cmake_executable(), '--build', str(self.build_directory), '--config', profile, '--', '-j',
                '%d' % os.cpu_count()]
        exit_code = subprocess.call(args, cwd=str(self.build_directory))
        if exit_code != 0:
            command = ' '.join(args)
            raise Exception(f"{self.platform} build failed: {exit_code}, command is: {command}")
        print(f"{self.build_directory}")
        output_apps = list(self.build_directory.rglob("*helloworld"))
        if len(output_apps) == 0:
            raise Exception('Oop! Something went wrong')

        self.logger.info('Build completed')
        for output_app in output_apps:
            self.logger.info('Output %s', Path(output_app))
