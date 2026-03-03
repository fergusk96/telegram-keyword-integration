# Telegram Keyword Integration

Lightweight helper to run `telegram_keywords.py` with a reproducible virtualenv and Termux-friendly persistent mode.

Prerequisites
- Python 3 (system `python3`)
- `make`
- On Termux: `termux-wake-lock` available for keeping the device awake

Quickstart

- Install dependencies into a local venv and run the script (recommended):

```bash
make install
make run
```

- Run persistently on Termux (creates separate Termux venv):

```bash
make termux-install
make termux-run
```

Stopping the Termux background process

```bash
make termux-stop
```

Cleanup

```bash
make clean         # remove local venv
make termux-clean  # remove Termux venv, pidfile and logfile
```

Files of interest
- `telegram_keywords.py` — main script
- `requirements.txt` — Python dependencies
- `Makefile` — targets for venv, install, run, and Termux background management

Notes
- Termux background run writes a pidfile (`telegram_keywords.termux.pid`) and a logfile (`telegram_keywords.termux.log`) in the project directory; these names can be overridden by setting `PIDFILE` and `LOGFILE` when invoking `make`.
- The Termux target uses `termux-wake-lock` to try to keep the device awake; if not available it will continue without failing.


