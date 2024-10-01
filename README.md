# Argo-Phoenix

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

## Using Go

To start from scratch with Go, run

```bash
bazel run @rules_go//go mod init github.com/SBolo/argo-phoenix
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
    importpath = "github.com/SBolo/argo-phoenix/test-go",
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
