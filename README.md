# GCP Image Builder

Create GCP disk images with up-to-date software using Packer.

Currently supported distros:

- `Ubuntu Pro 18 LTS`
- `Ubuntu Pro 20 LTS`
- `Ubuntu Pro 22 LTS`

Images are updated periotically with GitHub Actions to get the latest software preinstalled.

### Creating VM with built image

```bash
./create_vm.sh
```

### Building Images Manually

```bash
cd packer
# use default project and zone
./build_all.sh $(gcloud config get project) $(gcloud config get compute/zone)
```
