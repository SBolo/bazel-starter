load("@aspect_bazel_lib//lib:transitions.bzl", "platform_transition_filegroup")
load("@rules_oci//oci:defs.bzl", "oci_tarball")
load("//tools:py_layer.bzl", "py_oci_image")

def py_image(name, base, binary, entrypoint):
    py_oci_image(
        name = "image",
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
        srcs = [":image"],
        target_platform = select({
            "@platforms//cpu:arm64": ":aarch64_linux",
            "@platforms//cpu:x86_64": ":x86_64_linux",
        }),
    )