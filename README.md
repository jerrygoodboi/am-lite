# am-lite

Minimalist Application Manager for AppImages and Portable Apps.

## Features
- **Lite:** Single script, no local database bulk.
- **Fast:** Uses `aria2c` for multi-connection downloads.
- **Compatible:** Works with the 2500+ scripts from the [AM database](https://github.com/ivan-hc/AM).

## Commands
- `./am-lite -i <app>` : Install an application.
- `./am-lite -r <app>` : Remove an application.
- `./am-lite -u`       : Update all installed applications.

## Installation
To use `am-lite` globally:
```bash
sudo cp am-lite /usr/local/bin/am-lite
sudo chmod +x /usr/local/bin/am-lite
```

## Dependencies
- `bash`
- `curl`
- `aria2`
- `sudo`
