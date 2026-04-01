from setuptools import setup, find_packages

setup(
    name="mycli",
    version="1.0.0",
    description="Internal CLI SDK by Platform Team",
    packages=find_packages(),
    python_requires=">=3.8",
    entry_points={
        # Đây là điểm quan trọng: khi install xong, user gõ "mycli" là chạy được
        "console_scripts": [
            "mycli=mycli.main:main",
        ],
    },
)
