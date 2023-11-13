# `ccc`, also known as the `cookiecutter-cutter` :)

A cross-platform, self-contained `cookiecutter` runner that works in restricted environments, such as corporate laptops/VMs that don't allow you to install software.

The only thing you really need is to be able to write to your own `$HOME` dir, have a supported shell:

- macOS, GNU/Linux: `bash`, `zsh`
- Windows: `powershell`

## Caveats

### CLI capabilities

Ok, actually, there is another requirement, but it probably doesn't affect the typical user. You should have the ability to download files and unpack them with your shell. Powershell users have all of this built-in, and Linux/macOS users probably have at least `curl` (or `wget`) and `unzip` out of the box, unless you are running this from within a container or an embedded distribution.

### Architecture

The only architectures built here are:

- `amd64` (macOS, Windows, Linux -- only `glibc`, not `musl`!)
- `arm64` (macOS on Apple Silicon)
