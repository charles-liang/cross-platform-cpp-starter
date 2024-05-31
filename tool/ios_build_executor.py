import logging
import os
import subprocess
from pathlib import Path

from build_executor import BuildExecutor
from cmake_utils import get_cmake_executable


class IOSBuildExecutor(BuildExecutor):
    def __init__(self, source_directory: Path):
        self.os = 'IOS'
        self.logger = logging.getLogger(__name__)

    def build(self, platform: str, source_directory: Path, build_directory: Path, profile: str, arch: str):
        self.build_directory = Path(source_directory, 'build', f'{self.os}-{arch}'.lower())
        self.logger.info('Building %s', self.os)
        args = [get_cmake_executable(), 
                '--build', str(self.build_directory), 
                '--config', profile, 
                '--', 
                '-allowProvisioningUpdates',
                '-j', '%d' % os.cpu_count()]
        command = ' '.join(args)
        self.logger.info(f"{self.os} build command: {command}")
        exit_code = subprocess.call(command, shell=True, cwd=str(self.build_directory))
        if exit_code != 0:
            raise Exception(f"{self.os} build failed: {exit_code}, command is: {command}")

        # output_apps = list(self.build_directory.rglob("*helloworld*.app"))
        # if len(output_apps) == 0:
        #     raise Exception('Oop! Something went wrong')

        self.logger.info('Build completed')
        subprocess.run(['open', Path(self.source_directory, 'build', f'ios-{arch}', 'helloworld.xcodeproj')])
        # for output_app in output_apps:
        #     self.logger.info('Output %s', Path(output_app))
