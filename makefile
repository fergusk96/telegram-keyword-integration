
.PHONY: help venv install run clean

VENV?=.venv
PYTHON=$(VENV)/bin/python
PIP=$(VENV)/bin/pip
PIDFILE?=telegram_keywords.pid
LOGFILE?=telegram_keywords.log

help:
	@echo "Usage: make [target]"
	@echo "Targets:"
	@echo "  venv     Create a virtualenv at $(VENV)"
	@echo "  install  Install requirements from requirements.txt into $(VENV)"
	@echo "  run      Run telegram_keywords.py using the venv python"
	@echo "  clean    Remove the virtualenv"

venv:
	python3 -m venv --copies $(VENV)
	$(PYTHON) -m ensurepip --upgrade
	$(PYTHON) -m pip install --upgrade pip setuptools wheel

install: venv
	$(PIP) install -r requirements.txt

run: install
	$(PYTHON) telegram_keywords.py

run-persistent:
	nohup $(PYTHON) telegram_keywords.py  >> $(LOGFILE) 2>&1 & echo \$! > $(PIDFILE)

clean:
	rm -rf $(VENV)

