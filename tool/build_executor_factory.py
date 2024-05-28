import subprocess
from pathlib import Path

from android_build_executor import AndroidBuildExecutor
from cygwin_build_executor import CygwinBuildExecutor
from macos_build_executor import MacOSBuildExecutor
from unix_build_executor import UnixBuildExecutor

BUILD_DIRECTORY = 'build'


class BuildExecutorFactory:
    def __init__(self, source_directory: Path, platform: str):
        self.source_directory = source_directory
        self.platform = platform
        self.build_directory = Path(source_directory, BUILD_DIRECTORY)

    def build(self, profile: str):
        if self.platform == 'android':
            build_executor = AndroidBuildExecutor(self.source_directory)
        elif self.platform == 'ios':
            # build_executor = IOSBuildExecutor(self.source_directory)
            subprocess.run(['open', Path(self.source_directory, 'build', 'ios', 'helloworld.xcodeproj')])
            return
        elif self.platform == 'windows':
            build_executor = CygwinBuildExecutor(self.source_directory)
        elif self.platform == 'linux':
            build_executor = UnixBuildExecutor(self.source_directory)
        elif self.platform == 'macos':
            build_executor = MacOSBuildExecutor(self.source_directory)
        else:
            raise Exception('Unsupported platform %s' % self.platform)
        
        build_executor.pre_build(profile)
        build_executor.build(profile)
        build_executor.post_build(profile)
