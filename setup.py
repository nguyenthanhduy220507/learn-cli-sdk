from setuptools import setup, find_packages

setup(
    name="ikigai",
    version="1.0.4",
    description="Internal CLI SDK by Platform Team",
    packages=find_packages(),
    python_requires=">=3.8",
    install_requires=[
        "rich>=13.0.0",
        "google-genai>=0.1.0",
        "python-dotenv>=1.0.0",
    ],
    entry_points={
        # Đã đổi từ mycli thành ikigai
        "console_scripts": [
            "ikigai=mycli.main:main",
        ],
    },
)
