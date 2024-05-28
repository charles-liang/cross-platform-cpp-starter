import logging
import os
import platform
import subprocess
from pathlib import Path

from build_executor import BuildExecutor
from cmake_utils import get_cmake_executable


class MacOSBuildExecutor(BuildExecutor):
    def __init__(self, source_directory: Path):
        self.platform = 'macos'
        # TODO: need to from parent
        self.arch = 'x86_64' if platform.machine() == 'x86_64' else 'arm64'
        self.source_directory = source_directory
        self.build_directory = Path(source_directory, 'build', self.platform)
        self.logger = logging.getLogger(__name__)

    def build(self, profile: str):
        #TODO: need to from parent
        build_path = f'{self.build_directory}-{self.arch}'
        args = [get_cmake_executable(), '--build', build_path, '--config', profile, '--', '-j',
                '%d' % os.cpu_count()]
        exit_code = subprocess.call(args, cwd=str(build_path))
        if exit_code != 0:
            command = ' '.join(args)
            raise Exception(f"{self.platform} build failed: {exit_code}, command is: {command}")
        print(f"{build_path}")
        output_apps = list(Path(build_path).rglob("*helloworld"))
        if len(output_apps) == 0:
            raise Exception('Oop! Something went wrong')

        self.logger.info('Build completed')
        for output_app in output_apps:
            self.logger.info('Output %s', Path(output_app))
