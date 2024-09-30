# Argo-Phoenix

## Python images

This repository provides a custom rule to build Python images. In your BUILD.bazel file, you can write:

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

This repository also provides a custom rule to build Go images. In your BUILD.bazel file, you can write:

```starlark
load("@rules_go//go:def.bzl", "go_binary", "go_library")
load("@rules_oci//oci:defs.bzl", "oci_tarball", "oci_push")
load("//tools:rules_image.bzl", "go_image", "REMOTE_REPOSITORY")

REPO = "test-go"

go_library(
    name = "app_lib",
    ...
)

go_binary(
    name = "app",
    embed = [":app_lib"],
    visibility = ["//visibility:public"],
)

go_image(
    name = "image",
    srcs = [":app"],
    entrypoint = "/app",
)

oci_push(
    name = "artifact_release",
    image = ":image",
    repository = REMOTE_REPSITORY,
    remote_tags = [REPO],
)
```
