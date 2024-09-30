# Argo-Phoenix

## Python images

This repository provides a rule to build Python images. In your BUILD.bazel file, you can write:

```starlark
load("@rules_python//python:defs.bzl", "py_binary")
load("@rules_oci//oci:defs.bzl", "oci_tarball", "oci_push")
load("//tools:rules_image.bzl", "py_image", "REMOTE_REPSITORY")

REPO = "..."  # the name of your repository

py_binary(
    name = "my_binary",
    ...
)

py_image(
    name = "image",
    base = "@python-bookworm",
    binary = "main",
    entrypoint = REPO + "/main",
)

# builds image executable with 
# docker run --rm gcr.io/oci_python_main:latest
oci_tarball(
    name = "tarball",
    image = ":image",
    repo_tags = ["local:" + REPO],
)

oci_push(
    name = "artifact_release",
    image = ":image",
    repository = REMOTE_REPSITORY,
    remote_tags = [REPO],
)
```

## Go images


