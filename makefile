
.PHONY: help venv install run run-persistent run-qrcode stop clean

VENV?=.venv
PYTHON=$(VENV)/bin/python
PIP=$(VENV)/bin/pip
PIDFILE?=telegram_keywords.pid
LOGFILE?=telegram_keywords.log

help:
	@echo "Usage: make [target]"
	@echo "Targets:"
	@echo "  venv            Create a virtualenv at $(VENV)"
	@echo "  install         Install requirements from requirements.txt"
	@echo "  run             Run telegram_keywords.py"
	@echo "  run-persistent  Run telegram_keywords.py in background (log: $(LOGFILE))"
	@echo "  run-qrcode      Run qrcode.py"
	@echo "  stop            Stop background process"
	@echo "  clean           Remove the virtualenv"

venv:
	python3 -m venv --copies $(VENV)
	$(PYTHON) -m ensurepip --upgrade
	$(PYTHON) -m pip install --upgrade pip setuptools wheel

install: venv
	$(PIP) install -r requirements.txt

run: install
	$(PYTHON) telegram_keywords.py

run-persistent:
	nohup $(PYTHON) telegram_keywords.py >> $(LOGFILE) 2>&1 & echo $$! > $(PIDFILE)

run-qrcode: install
	$(PYTHON) qrcode.py

stop:
	kill $$(cat $(PIDFILE))

clean:
	rm -rf $(VENV)

	