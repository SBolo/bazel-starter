load("@aspect_rules_py//py:defs.bzl", "py_binary", "py_library")
load("@aspect_bazel_lib//lib:transitions.bzl", "platform_transition_filegroup")
load("@pip//:requirements.bzl", "requirement")
load("@rules_oci//oci:defs.bzl", "oci_tarball")
load("//:py_layer.bzl", "py_oci_image")

def python_image(name, binary, entrypoint, base = "@ubuntu", tags = ["gcr.io/oci_python_main:latest"]):
    py_oci_image(
        name = "image",
        base = base,
        binary = binary,
        entrypoint = entrypoint,
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
        name = "platform_image",
        srcs = [":image"],
        target_platform = select({
            "@platforms//cpu:arm64": ":aarch64_linux",
            "@platforms//cpu:x86_64": ":x86_64_linux",
        }),
    )

    oci_tarball(
        name = name,
        image = ":platform_image",
        repo_tags = tags,
    )