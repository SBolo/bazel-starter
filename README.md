# Bazel Starter

This repo is meant to provide with an off-the-shelf and functioning starter repository to get going with Bazel for a Python and Go project. It does not allow you to do anything particularly advanced but it serves the purpose of illustrating the main steps that one needs to take into account when setting up a Bazel project from scratch.

## Some bazic tidiness

The repository is structured in language-based repositories, `python` and `golang`, each of which will contain modules. Each `BUILD.bazel` file in modules should contain targets for creating a local image (`oci_tarball`, named `tarball`) and to push an image to Docker Hub (`oci_push`, named `artifact_release`).

For now, because I am working on an Mac M1 chip, all the images I produce are in `linux/arm64` architecture. This might change if I decide to move to using `dazel`.

Images generated from the `oci_tarball` rule can be run with:

```shell
docker run --rm <name>:<tag>
```

## Using Python

### Adding new dependencies

To add new dependencies, you can add the specific requirement into the `requirements.txt` file and run

```shell
bazel run requirements.update
```

to update the `requirements_lock.txt` file.

### Python images

This repository provides a custom rule (defined in `tools/rules_artifacts.bzl`) to build Python images. In your `BUILD.bazel` file, you can write:

```starlark
load("@rules_python//python:defs.bzl", "py_binary")
load("@rules_oci//oci:defs.bzl", "oci_tarball", "oci_push")
load("//tools:rules_image.bzl", "py_image", "REMOTE_REPOSITORY")

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
    repository = REMOTE_REPOSITORY,
    remote_tags = [REPO],
)
```

### Python linting

This repository supports Python linting with `ruff`. To run linting for python packages, you can run

```starlark
bazel lint //python:all
```

## Using Go

To start from scratch with Go, run

```bash
bazel run @rules_go//go mod init github.com/SBolo/bazel-starter
bazel run @rules_go//go mod tidy
```

To add a dependency, run

```bash
bazel run @rules_go//go get <dep>@<version>
bazel mod tidy
```

The second command ensures that the dependency is correctly added to the `MODULE.bazel` file. If necessary, `gazelle` can be employed to automatically create `go_library` targets for you:

```bash
bazel run //:gazelle
```

would generate something like

```starlark
go_library(
    name = "test-go_lib",
    srcs = ["main.go"],
    importpath = "github.com/SBolo/bazel-starter/test-go",
    visibility = ["//visibility:private"],
    deps = ["@org_go4_netipx//:netipx"],
)
```

in a repository called `test-repo` containing only `main.go`. All dependencies in `go.mod` will automatically be added, unless

```starlark
# gazelle:prefix github.com/example/project
```

is specified in the `BUILD.bazel` file.

### Go images

This repository also provides a custom rule (defined in `tools/rules_artifacts.bzl`) to build Go images. In your `BUILD.bazel` file, you can write:

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

## Formatting

To run format your code, run

```shell
bazel run //:format
```

To check, instead, if the code is formatter-compliant, run

```shell
bazel run //tools/format:format.check
```

Currently, this repository supports formatting of Python, Golang, Terraform, Bash, JSON and YAML. Both commands will run the formatters on all the code in the repository. If you would rather run a formatting check on some specific package, you can add the target

```starlark
format_test(
    name = "format_test",
    python = "@aspect_rules_lint//format:ruff",
    srcs = ["main.py"],
)
```

to your `BUILD.bazel` file. The specific binary for the formatter can be picked from the examples in `tools/format/BUILD.bazel`.
