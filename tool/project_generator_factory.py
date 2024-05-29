from pathlib import Path

from android_project_generator import AndroidProjectGenerator
from cygwin_project_generator import CygwinProjectGenerator
from ios_project_generator import IOSProjectGenerator
from macos_project_generator import MacOSProjectGenerator
from unix_project_generator import UnixProjectGenerator


class ProjectGeneratorFactory:

    def generate(self, platform: str, source_directory: Path, build_directory: Path, profile: str, arch: str):
        if platform == 'android':
            project_generator = AndroidProjectGenerator()
        elif platform == 'ios':
            project_generator = IOSProjectGenerator()
        elif platform == 'windows':
            project_generator = CygwinProjectGenerator()
        elif platform == 'linux':
            project_generator = UnixProjectGenerator()
        elif platform == 'macos':
            project_generator = MacOSProjectGenerator()
        else:
            raise Exception('Unsupported platform %s' % platform)
        project_generator.pre_generate(source_directory, build_directory, profile, arch)
        project_generator.generate(source_directory, build_directory, profile, arch)
        project_generator.post_generate(source_directory, build_directory, profile, arch)
