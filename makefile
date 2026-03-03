
.PHONY: help venv install run clean termux-venv termux-install termux-run termux-stop termux-clean

VENV?=.venv
PYTHON=$(VENV)/bin/python
PIP=$(VENV)/bin/pip

# Termux-specific virtualenv and runtime
VENV_TERMUX?=.termux_venv
PYTHON_TERMUX=$(VENV_TERMUX)/bin/python
PIP_TERMUX=$(VENV_TERMUX)/bin/pip
PIDFILE?=telegram_keywords.termux.pid
LOGFILE?=telegram_keywords.termux.log

help:
	@echo "Usage: make [target]"
	@echo "Targets:"
	@echo "  venv     Create a virtualenv at $(VENV)"
	@echo "  install  Install requirements from requirements.txt into $(VENV)"
	@echo "  run      Run telegram_keywords.py using the venv python"
	@echo "  clean    Remove the virtualenv"
	@echo "  termux-venv   Create a Termux virtualenv at $(VENV_TERMUX)"
	@echo "  termux-install Install requirements into $(VENV_TERMUX)"
	@echo "  termux-run    Run telegram_keywords.py in background (Termux)"
	@echo "  termux-stop   Stop Termux background run"
	@echo "  termux-clean  Remove the Termux venv"

venv:
	python3 -m venv $(VENV)
	$(PYTHON) -m pip install --upgrade pip setuptools wheel

install: venv
	$(PIP) install -r requirements.txt

run: install
	$(PYTHON) telegram_keywords.py

run-persistent:
	nohup $(PYTHON) telegram_keywords.py  >> $(LOGFILE) 2>&1 & echo \$! > $(PIDFILE)

# Termux targets: create a separate venv and run persistently in background.
termux-venv:
	python3 -m venv $(VENV_TERMUX)
	$(PYTHON_TERMUX) -m pip install --upgrade pip setuptools wheel

termux-install: termux-venv
	$(PIP_TERMUX) install -r requirements.txt

termux-run: termux-install
	@echo "Starting telegram_keywords.py in background (Termux). Log: $(LOGFILE)"
	termux-wake-lock || true
	nohup $(PYTHON_TERMUX) telegram_keywords.py >> $(LOGFILE) 2>&1 & echo \$! > $(PIDFILE)

termux-stop:
	@if [ -f $(PIDFILE) ]; then \
		kill `cat $(PIDFILE)` 2>/dev/null || true; \
		rm -f $(PIDFILE); \
		echo "Stopped Termux background process"; \
	else \
		echo "No Termux pidfile found"; \
	fi
	termux-wake-unlock || true

termux-clean:
	rm -rf $(VENV_TERMUX) $(PIDFILE) $(LOGFILE)

clean:
	rm -rf $(VENV)

