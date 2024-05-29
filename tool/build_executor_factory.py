import subprocess
from pathlib import Path

from android_build_executor import AndroidBuildExecutor
from cygwin_build_executor import CygwinBuildExecutor
from macos_build_executor import MacOSBuildExecutor
from ios_build_executor import IOSBuildExecutor
from unix_build_executor import UnixBuildExecutor

BUILD_DIRECTORY = 'build'


class BuildExecutorFactory:
    def __init__(self, source_directory: Path, platform: str):
        self.source_directory = source_directory
        self.platform = platform
        self.build_directory = Path(source_directory, BUILD_DIRECTORY)

    def build(self, platform: str, source_directory: Path, build_directory: Path, profile: str, arch: str):
        _arch = None
        if self.platform == 'android':
            build_executor = AndroidBuildExecutor(self.source_directory)
        elif self.platform == 'ios':
            build_executor = IOSBuildExecutor(self.source_directory)
            _arch = arch if arch else 'arm64'
        elif self.platform == 'windows':
            build_executor = CygwinBuildExecutor(self.source_directory)
        elif self.platform == 'linux':
            build_executor = UnixBuildExecutor(self.source_directory)
        elif self.platform == 'macos':
            _arch = arch if arch else 'arm64'
            build_executor = MacOSBuildExecutor(self.source_directory)
        else:
            raise Exception('Unsupported platform %s' % self.platform)
        
        build_executor.pre_build(platform, source_directory, build_directory, profile, _arch)
        build_executor.build(platform, source_directory, build_directory, profile, _arch)
        build_executor.post_build(platform, source_directory, build_directory, profile, _arch)
