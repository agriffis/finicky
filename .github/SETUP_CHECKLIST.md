# Repository Setup Checklist

## Initial Setup

### 1. Rename Template
- [x] Updated `finpilot` to `finicky` in: Containerfile, Justfile, README.md, artifacthub-repo.yml, clean.yml, custom/ujust/README.md

### 2. Enable GitHub Actions
- [ ] Settings → Actions → General → Enable workflows
- [ ] Set "Read and write permissions"

### 3. First Push
```bash
git add .
git commit -m "feat: initial customization"
git push origin main
```

### 4. Deploy
```bash
sudo bootc switch --transport registry ghcr.io/agriffis/finicky:stable
sudo systemctl reboot
```

## Optional: Production Features

### Enable Signing (Recommended)
```bash
cosign generate-key-pair
# Add cosign.key to GitHub Secrets as SIGNING_SECRET
# Uncomment signing in .github/workflows/build.yml
```

