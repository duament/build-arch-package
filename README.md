# Build Arch Linux package Github Action

```yaml
jobs:
  my-job:
    ...
    container:
      image: archlinux
      options: --privileged
      volumes:
        - /sys/fs/cgroup:/sys/fs/cgroup
    steps:
      ...
      - name: Build Arch Linux package
        uses: FFY00/build-arch-package@v1
        with:
          PKGBUILD: path/to/PKGBUILD/dir
      ...
```

See [.github/workflows/test.yml](.github/workflows/test.yml) for a working example.

### Arguments

Key        | Description                                 | Required | Default Value
---------- | ------------------------------------------- |:--------:| -------------
`PKGBUILD` | PKGBUILD directory                          | **Yes**  |
`OUTDIR`   | Output directory to store the built package | No       | `$HOME/arch-packages`

###### You can use environment variable names in the options, they will be resolved.
