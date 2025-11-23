precommit:
    pre-commit install

release:
    ./scripts/release.sh

docs:
    helm-docs

fmt:
    prettier --write .
