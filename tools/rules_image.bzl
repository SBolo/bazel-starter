load("@aspect_bazel_lib//lib:transitions.bzl", "platform_transition_filegroup")
load("@rules_oci//oci:defs.bzl", "oci_tarball")
load("//tools:py_layer.bzl", "py_oci_image")
load("@rules_pkg//:pkg.bzl", "pkg_tar")
load("@rules_oci//oci:defs.bzl", "oci_image")

REMOTE_REPSITORY = "index.docker.io/sbolo/argo-phoenix-test"

def py_image(name, binary, entrypoint, base = "@python-bookworm"):
    py_oci_image(
        name = "__generic_image",
        base = base,
        binary = binary,
        entrypoint = [entrypoint],
    )

    native.platform(
        name = "aarch64_linux",
        constraint_values = [
            "@platforms//os:linux",
            "@platforms//cpu:aarch64",
        ],
    )

    native.platform(
        name = "x86_64_linux",
        constraint_values = [
            "@platforms//os:linux",
            "@platforms//cpu:x86_64",
        ],
    )

    platform_transition_filegroup(
        name = name,
        srcs = [":__generic_image"],
        target_platform = select({
            "@platforms//cpu:arm64": ":aarch64_linux",
            "@platforms//cpu:x86_64": ":x86_64_linux",
        }),
    )

def go_image(name, srcs, entrypoint, base = "@golang-bookworm"):
    # Put app go_binary into a tar layer.
    pkg_tar(
        name = "__pkg_layer",
        srcs = srcs,
    )

    oci_image(
        name = "__generic_image",
        base = base,
        entrypoint = [entrypoint],
        tars = [":__pkg_layer"],
    )

    platform_transition_filegroup(
        name = name,
        srcs = [":__generic_image"],
        target_platform = select({
            "@platforms//cpu:arm64": "@rules_go//go/toolchain:linux_arm64",
            "@platforms//cpu:x86_64": "@rules_go//go/toolchain:linux_amd64",
        }),
    )