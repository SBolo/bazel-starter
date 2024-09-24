load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")
 
 
# Update the SHA and VERSION to the lastest version available here:
# https://github.com/bazelbuild/rules_python/releases.
 
load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

http_archive(
    name = "rules_python",
    sha256 = "ca77768989a7f311186a29747e3e95c936a41dffac779aff6b443db22290d913",
    strip_prefix = "rules_python-0.36.0",
    url = "https://github.com/bazelbuild/rules_python/releases/download/0.36.0/rules_python-0.36.0.tar.gz",
)

load("@rules_python//python:repositories.bzl", "py_repositories")

py_repositories()
 
load("@rules_python//python:repositories.bzl", "python_register_toolchains")
 
python_register_toolchains(
    name = "python_3_11",
    # Available versions are listed in @rules_python//python:versions.bzl.
    # We recommend using the same version your team is already standardized on.
    python_version = "3.11",
)
 
load("@python_3_11//:defs.bzl", "interpreter")
 
load("@rules_python//python:pip.bzl", "pip_parse")
 
# Create a central repo that knows about the dependencies needed from
# requirements_lock.txt.
pip_parse(
   name = "pip",
   requirements_lock = "//:requirements_lock.txt",
)
# Load the starlark macro, which will define your dependencies.
load("@pip//:requirements.bzl", "install_deps")
# Call it to define repos for your requirements.
install_deps()