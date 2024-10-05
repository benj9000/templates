# My templates

A collection of different templates.

## Usage

In general, a template can be realized with the following commands:

```sh
# In the current directory:
nix flake init --template <flakeref>#<templateref>
# Or in a specified directory:
nix flake new --template <flakeref>#<templateref> <targetdir>
```
where
- `<flakeref>` is a reference to a flake providing the template,
- `<templateref>` is a reference to a template provided by the flake, and
- `<targetdir>` is the target directory, where the template will be realized.

### From a local clone of this repository

```sh
nix flake init --template /path/to/local/repository#<templateref>
# Or
nix flake new --template /path/to/local/repository#<templateref> <targetdir>
```

### Directly from GitHub

```sh
nix flake init --template github:benj9000/templates#<templateref>
# Or
nix flake new --template github:benj9000/templates#<templateref> <targetdir>
```

## Licence

Distributed under the [MIT](https://spdx.org/licenses/MIT.html) licence. See [LICENSE.md](./LICENSE.md) for more information.
