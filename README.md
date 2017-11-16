## Pipeline's Control Plane Image creation 

### List targets
```bash
make list
```

### Dry run
```bash
DRY_RUN=1 \
make build-aws-ubuntu-xenial
```

### Run with user environment
```bash
cp .env.example .env

# Please fill empty vars
source .env

make build-aws-ubuntu-xenial
```

### Supported regions

```
eu-west-1
```

## Latest Image

* eu-west-1:  `ami-9f8532e6`
