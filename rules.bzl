load("@aspect_bazel_lib//lib:transitions.bzl", "platform_transition_filegroup")
load("@rules_oci//oci:defs.bzl", "oci_tarball")

def local_image(name, image_target, tag):
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
        srcs = [image_target],
        target_platform = select({
            "@platforms//cpu:arm64": ":aarch64_linux",
            "@platforms//cpu:x86_64": ":x86_64_linux",
        }),
    )

    oci_tarball(
        name = name,
        image = ":platform_image",
        repo_tags = [tag],
    )