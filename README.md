# Argo-Phoenix

## Custom Bazel rules

To create a Python or Go image to run locally for testing, use the following in your BUILD.bazel:

```starlark
load("//tools:rules.bzl", "local_image")

local_image(
    name = "tarball",
    image_target = ":image",
    tag = "test-repo:local",
)
```

And then you can run it as

```bash
bazel run //repo:target
docker run --rm test-repo:local
```
