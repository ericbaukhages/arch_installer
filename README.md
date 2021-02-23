# Arch Installer

Based on Matthieu Cneude's arch_install from https://themouseless.dev/

Originally found here: https://github.com/Phantas0s/ArchInstall

## Instructions

Boot the Arch Linux live system from USB, and connect to the internet. Then you can run the following commands:

```bash
curl -LO https://raw.githubusercontent.com/ericbaukhages\
/arch_installer/main/install_sys.sh
bash install_sys.sh
```

On another `tty`, you can follow the install with:

```bash
tail -f /tmp/arch_install
```
