from abc import abstractmethod


class BuildExecutor:
    def pre_build(self, profile: str):
        print("Preparing build", profile)
        pass
    @abstractmethod
    def build(self, profile: str):
        pass

    def post_build(self, profile: str):
        print("Build finished", profile)
        pass