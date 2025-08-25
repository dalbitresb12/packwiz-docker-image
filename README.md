# packwiz-docker-image

This repository contains the configuration for the (unofficial) Docker image for [packwiz](https://github.com/packwiz/packwiz).

## Volumes

- `/workspace`: you can mount your packwiz modpack to this directory with read-write perms and packwiz will be able to modify your modpack from Docker.
- `/data`: you can mount your packwiz modpack to this directory with read-only perms. An [entrypoint script](#why-the-entrypoint-script) will copy all the files to `/workspace` so that you can modify the files content without touching the original files.

## Examples

### Initializing a modpack

> If you need to respond to any prompts interactively, use `-it` in your `docker run` command.

```bash
$ docker run -it --rm -v "$(pwd)":/workspace dalbitresb12/packwiz init
Modpack name [Workspace]: My Awesome Modpack
Author: dalbitresb12
Version [1.0.0]:
Minecraft version [1.21.1]:
Mod loader [quilt]: fabric
Fabric loader version [0.16.2]:
Refreshing index... 0 % [------------------------------------------------------------------------------] done
pack.toml created!
$ ls -lh
total 8.0K
-rw-r--r-- 1 root root  34 Aug 22 20:37 index.toml
-rw-r--r-- 1 root root 250 Aug 22 20:37 pack.toml
```

#### Running as a different user

The image by default uses `root` as the user inside the container. You can change that using the `--user` flag from the Docker CLI.

> You can use `id -u` and `id -g` to get your current user and group ID.

```bash
$ docker run -it --user "$(id -u):$(id -g)" --rm -v "$(pwd)":/workspace dalbitresb12/packwiz init
Modpack name [Workspace]: My Awesome Modpack
Author: dalbitresb12
Version [1.0.0]:
Minecraft version [1.21.1]:
Mod loader [quilt]: fabric
Fabric loader version [0.16.2]:
index.toml created!
Refreshing index... 0 % [------------------------------------------------------------------------------] done
pack.toml created!
$ ls -lh
total 8.0K
-rw-r--r-- 1 dab12 dab12  34 Aug 22 20:42 index.toml
-rw-r--r-- 1 dab12 dab12 277 Aug 22 20:42 pack.toml
```

### Adding a mod

> You can auto-accept most prompts in packwiz in non-interactive mode using the `-y` flag.

```bash
$ docker run --user "$(id -u):$(id -g)" --rm -v "$(pwd)":/workspace dalbitresb12/packwiz modrinth add iris -y
Finding dependencies...
Dependencies found:
Sodium
Would you like to add them? [Y/n]: Y (non-interactive mode)
Dependency "Sodium" successfully added! (sodium-fabric-0.6.0-beta.1+mc1.21.jar)
Project "Iris Shaders" successfully added! (iris-fabric-1.8.0-beta.1+mc1.21.1.jar)
```

### Listing all mods

```bash
$ docker run --rm -v "$(pwd)":/workspace dalbitresb12/packwiz list
Iris Shaders
Sodium
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

- `GO_VERSION`: a valid tag for the [Golang Docker image](https://hub.docker.com/_/golang) which is used for the builder image.
- `HEAD_REF`: a valid Git ref (commit, branch or tag) to be used in the command `git reset --hard ${HEAD_REF}`.

## Why the entrypoint script?

I needed a way to build my private server modpack for distribution from a repository cloned on the server without modifying the original files. The built files (with the hashes) would be saved to a volume that another container running nginx could use to serve the files from there.

Previously, I was building the modpack for distribution during the custom nginx image build, but I wanted a way to not have to rebuild the nginx image when the modpack changed (therefore restarting the container and dropping connections from other things my nginx proxy was doing).

I don't know if this is the best way to do this but it works.

## License

[MIT](LICENSE)
