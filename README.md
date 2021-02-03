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
        uses: duama/build-arch-package@master
        env:
          TOKEN: ${{ secrets.TOKEN }}
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
          PUBKEY_DIR: /gpg_keys
        with:
          DIR: path/to/PKGBUILD_DIR
      ...
```

### Arguments

Key            | Description               | Required | Type
-------------- | ------------------------- |:--------:| ------
`DIR`          | PKGBUILD directory        | **Yes**  | input
`TOKEN`        | Server token              | **Yes**  | env
`GITHUB_TOKEN` | GitHub token              | **Yes**  | env
`PUBKEY_DIR`   | GPG public keys directory | No       | env

