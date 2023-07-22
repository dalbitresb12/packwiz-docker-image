# packwiz-docker-image

This repository contains the configuration for the (unofficial) Docker image for [packwiz](https://github.com/packwiz/packwiz).

## Volumes

- `/workspace`: you can mount your packwiz modpack to this directory with read-write perms and packwiz will be able to modify your modpack from Docker.
- `/data`: you can mount your packwiz modpack to this directory with read-only perms. An [entrypoint script](#why-the-entrypoint-script) will copy all the files to `/workspace` so that you can modify the files content without touching the original files.

## Examples

### Adding a mod

```bash
$ docker run --rm -v "$(pwd)":/workspace dalbitresb12/packwiz modrinth add iris
Finding dependencies...
All dependencies are already added!
Project "Iris Shaders" successfully added! (iris-mc1.20-1.6.4.jar)
```

### Listing all mods

```bash
$ docker run --rm -v "$(pwd)":/workspace dalbitresb12/packwiz list
Iris Shaders
```

### Building modpack for distribution when using no-internal-hashes mode without touching original files

```bash
$ docker run --rm -v "$(pwd)":/data -v packwiz-build:/workspace dalbitresb12/packwiz refresh --build
[RUNNER] Found a valid packwiz modpack at /data, copying to /workspace...
Loading modpack...
Refreshing index... 100 % [==============================================================================] done
Index refreshed!
```

## Image Build Arguments

- `HEAD_REF`: a valid Git ref (commit, branch or tag) to be used in the command `git reset --hard ${HEAD_REF}`.

## Why the entrypoint script?

I needed a way to build my private server modpack for distribution from a repository cloned on the server without modifying the original files. The built files (with the hashes) would be saved to a volume that another container running nginx could use to serve the files from there.

Previously, I was building the modpack for distribution during the custom nginx image build, but I wanted a way to not have to rebuild the nginx image when the modpack changed (therefore restarting the container and dropping connections from other things my nginx proxy was doing).

I don't know if this is the best way to do this but it works.

## License

[MIT](LICENSE)
