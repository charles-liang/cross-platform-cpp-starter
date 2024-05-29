from abc import abstractmethod
from pathlib import Path


class BuildExecutor:
    def pre_build(self, platform: str, source_directory: Path, build_directory: Path, profile: str, arch: str):
        print("Preparing build", profile)
        pass
    @abstractmethod
    def build(self, platform: str, source_directory: Path, build_directory: Path, profile: str, arch: str):
        pass

    def post_build(self, platform: str, source_directory: Path, build_directory: Path, profile: str, arch: str):
        print("Build finished", profile)
        pass