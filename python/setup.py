from setuptools import setup, find_packages

setup(
    name="kylrix-sdk",
    version="0.1.0",
    packages=find_packages(),
    install_requires=[
        "appwrite>=6.1.0",
    ],
    author="Kylrix Organization",
    description="The official Kylrix SDK for Python.",
    license="MIT",
    keywords="kylrix sdk privacy encryption auth",
    url="https://github.com/kylrix/sdks-python",
)
