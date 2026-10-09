# Hugo Marotta's Fedora Setup

A Bash script to automate the setup of a new [Fedora Workstation] installation.

## Installation

### One-line

Open a terminal and run the following command:

```sh
bash -c "$(curl -fsSL https://github.com/humtta/fedora-setup/raw/main/boot.sh)"
```

### Manual

First, clone the repository:

```sh
git clone https://github.com/humtta/fedora-setup
```

Then, run the setup script from the cloned directory:

```sh
./setup.sh
```

## Post-installation

After running the script, restart your computer and follow these steps to
complete the system setup:

1. Import the GPG key, replacing `PATH` with the private key path:

   ```sh
   gpg --import PATH
   ```

2. Assign the highest trust level to the GPG key:

   ```sh
   echo '966EB8F0EADF8CF5156BC3704394243BBBC1AADD:6:' | gpg --import-ownertrust
   ```

3. Authenticate `gh` with GitHub:

   ```sh
   gh auth login -p https -h github.com -w
   ```

## License

This project is licensed under the [MIT License].

[Fedora Workstation]: https://fedoraproject.org/workstation
[mit license]: LICENSE.md
