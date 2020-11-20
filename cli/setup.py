from setuptools import setup, find_packages
from cli import constant

with open("README.md", "r") as fh:
    long_description = fh.read()

setup(
    name="dmb-cli",
    version=f'{constant.CLI_VER}',
    author="Kevin Liu",
    author_email="liukaikevin@didiglobal.com",
    description="CLI for DreamBox",
    long_description=long_description,
    long_description_content_type="text/markdown",
    url="http://github.com/didi/dreambox/cli",
    packages=find_packages(),
    include_package_data=True,
    classifiers=[
        "Programming Language :: Python :: 3",
        "Operating System :: OS Independent",
    ],
    install_requires=['lxml', 'watchdog', 'websockets', 'jinja2', 'qrcode', 'importlib-resources',
                      'netifaces', 'PyYAML'],
    entry_points={
        'console_scripts': ["dmb-cli=cli.main:cli"]
    },
    python_requires='>=3.6',
)
