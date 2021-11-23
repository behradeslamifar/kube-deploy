# Build image for Kubernetes Node
1. Edit preflight environment
```
vi prefilght.sh
```

2. Run preflight script
```
source preflight.sh
```

3. Build image
```
packer build template.json
```
