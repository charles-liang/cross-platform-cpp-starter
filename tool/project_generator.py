from abc import abstractmethod
from pathlib import Path


class ProjectGenerator:
    def pre_generate(self, source_directory: Path, build_directory: Path, profile: str, arch: str = None):
        print("Preparing project")
        print("Source directory: %s" % source_directory)
        pass
    @abstractmethod
    def generate(self, source_directory: Path, build_directory: Path, profile: str, arch: str = None):
        pass

    def post_generate(self, source_directory: Path, build_directory: Path, profile: str,  arch: str = None):
        print("Project generated")
        print("Build directory: %s" % build_directory)
        pass
