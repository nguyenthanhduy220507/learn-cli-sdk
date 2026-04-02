from setuptools import setup, find_packages

setup(
    name="ikigai",
    version="0.2.0",
    packages=find_packages(),
    install_requires=[
        "typer[all]",
        "rich",
        "httpx",
    ],
    entry_points={
        "console_scripts": [
            "ikigai=ikigai.main:app",
        ],
    },
)
