
## Production Checklist

- [x] **Enable Image Signing** (Recommended)
  - Provides cryptographic verification of your images
  - Prevents tampering and ensures authenticity
  - See "Optional: Enable Image Signing" section above for setup instructions
  - Status: **Disabled by default** to allow immediate testing

- [x] **Enable SBOM Attestation** (Recommended)
  - Generates Software Bill of Materials for supply chain security
  - Provides transparency about what's in your image
  - Requires image signing to be enabled first
  - To enable:
    1. First complete image signing setup above
    2. Edit `.github/workflows/build.yml`
    3. Find the "OPTIONAL: SBOM Attestation" section around line 232
    4. Uncomment the "Add SBOM Attestation" step
    5. Commit and push
  - Status: **Disabled by default** (requires signing first)

- [ ] **Enable Image Rechunking** (Recommended)
  - Optimizes bootc image layers for better update performance
  - Reduces update sizes by 5-10x
  - Improves download resumability with evenly sized layers
  - To enable:
    1. Edit `.github/workflows/build.yml`
    2. Find the "Build Image" step
    3. Add a rechunk step after the build (see example below)
  - Status: **Not enabled by default** (optional optimization)

### Adding Image Rechunking

After building your bootc image, add a rechunk step before pushing to the registry. Here's an example based on the workflow used by [zirconium-dev/zirconium](https://github.com/zirconium-dev/zirconium):

```yaml
- name: Build image
  id: build
  run: sudo podman build -t "${IMAGE_NAME}:${DEFAULT_TAG}" -f ./Containerfile .

- name: Rechunk Image
  run: |
    sudo podman run --rm --privileged \
      -v /var/lib/containers:/var/lib/containers \
      --entrypoint /usr/libexec/bootc-base-imagectl \
      "localhost/${IMAGE_NAME}:${DEFAULT_TAG}" \
      rechunk --max-layers 96 \
      "localhost/${IMAGE_NAME}:${DEFAULT_TAG}" \
      "localhost/${IMAGE_NAME}:${DEFAULT_TAG}"

- name: Push to Registry
  run: sudo podman push "localhost/${IMAGE_NAME}:${DEFAULT_TAG}" "${IMAGE_REGISTRY}/${IMAGE_NAME}:${DEFAULT_TAG}"
```

Alternative approach using a temporary tag for clarity:

```yaml
- name: Rechunk Image
  run: |
    sudo podman run --rm --privileged \
      -v /var/lib/containers:/var/lib/containers \
      --entrypoint /usr/libexec/bootc-base-imagectl \
      "localhost/${IMAGE_NAME}:${DEFAULT_TAG}" \
      rechunk --max-layers 67 \
      "localhost/${IMAGE_NAME}:${DEFAULT_TAG}" \
      "localhost/${IMAGE_NAME}:${DEFAULT_TAG}-rechunked"
    
    # Tag the rechunked image with the original tag
    sudo podman tag "localhost/${IMAGE_NAME}:${DEFAULT_TAG}-rechunked" "localhost/${IMAGE_NAME}:${DEFAULT_TAG}"
    sudo podman rmi "localhost/${IMAGE_NAME}:${DEFAULT_TAG}-rechunked"
```

**Parameters:**
- `--max-layers`: Maximum number of layers for the rechunked image (typically 67 for optimal balance)
- The first image reference is the source (input)
- The second image reference is the destination (output)
  - When using the same reference for both, the image is rechunked in-place
  - You can also use different tags (e.g., `-rechunked` suffix) and then retag if preferred

**References:**
- [CoreOS rpm-ostree build-chunked-oci documentation](https://coreos.github.io/rpm-ostree/build-chunked-oci/)
- [bootc documentation](https://containers.github.io/bootc/)
