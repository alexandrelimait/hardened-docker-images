# Hardened Docker Images

A collection of security-hardened Docker base images for Node.js and Python applications. These images follow security best practices and are designed for production use.

## 🛡️ Security Features

### Common Security Hardening
- **Non-root user**: All applications run as the `app` user (UID: 1001)
- **Package manager removal**: APK package manager is removed after installation
- **Dangerous command removal**: Tools like `curl`, `wget`, `nc`, `su`, `sudo` are removed
- **SUID/SGID removal**: All setuid and setgid permissions are stripped
- **User account cleanup**: Only essential users (`app`, `root`, `nobody`) remain
- **Password login disabled**: All user accounts have password login disabled
- **Strict permissions**: System directories are owned by root with restricted permissions
- **Temporary file cleanup**: All temporary files and caches are removed
- **System file removal**: Unnecessary system files and directories are removed

### Node.js Specific
- **Latest Node.js**: Based on official Node.js Alpine images
- **NPM security**: Configured for secure package management
- **Application isolation**: Applications run in `/app` directory

### Python Specific
- **Latest Python**: Based on official Python Alpine images
- **Pip security**: Configured with `--no-cache-dir` and version pinning
- **Python cleanup**: Removes `.pyc`, `.pyo` files and `__pycache__` directories
- **Application isolation**: Applications run in `/app` directory

## 🚀 Available Images

### Node.js Images
- `ghcr.io/nodejs-hardened-base:node-18-alpine`
- `ghcr.io/nodejs-hardened-base:node-20-alpine`
- `ghcr.io/nodejs-hardened-base:node-22-alpine`

### Python Images
- `ghcr.io/python-hardened-base:python-3.11-alpine`
- `ghcr.io/python-hardened-base:python-3.12-alpine`
- `ghcr.io/python-hardened-base:python-3.13-alpine`

## 📋 Usage

### Using Node.js Hardened Image

```dockerfile
# Use the hardened Node.js base image
FROM ghcr.io/nodejs-hardened-base:node-20-alpine

# Your application code
COPY package*.json ./
RUN npm ci --only=production

COPY . .
EXPOSE 3000

# Run as non-root user (already set in base image)
CMD ["node", "app.js"]
```

### Using Python Hardened Image

```dockerfile
# Use the hardened Python base image
FROM ghcr.io/python-hardened-base:python-3.12-alpine

# Your application code
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .
EXPOSE 8000

# Run as non-root user (already set in base image)
CMD ["python", "app.py"]
```

## 🔧 Building Locally

### Prerequisites
- Docker
- Bash shell

### Test Builds
Run the test script to verify all images build correctly:

```bash
./test-builds.sh
```

This will build and test all Node.js and Python images locally.

### Manual Build
To build a specific image:

```bash
# Node.js image
docker build \
  --build-arg BASE_IMAGE=node:20-alpine \
  -f .github/.images/Dockerfile.node \
  -t nodejs-hardened-base:node-20-alpine \
  .github/.images

# Python image
docker build \
  --build-arg BASE_IMAGE=python:3.12-alpine \
  -f .github/.images/Dockerfile.python \
  -t python-hardened-base:python-3.12-alpine \
  .github/.images
```

## 🔄 CI/CD Workflows

### Automated Builds
The repository includes GitHub Actions workflows that automatically build and push images:

1. **Main Workflow** (`build-push.yaml`): Builds both Node.js and Python images
2. **Reusable Workflow** (`reusable-build-image.yml`): Modular workflow for individual image builds
3. **All Images Workflow** (`build-all-images.yml`): Example using the reusable workflow

### Triggering Builds
- **Automatic**: Pushes to `.github/.images/` trigger builds
- **Manual**: Use GitHub Actions UI or CLI to trigger workflows
- **Scheduled**: Nightly builds (commented out by default)

### Manual Trigger
```bash
# Build all images
gh workflow run "Build Hardened Base Images"

# Build specific images
gh workflow run "Build Hardened Base Images" \
  --field base_images="node:20-alpine
python:3.12-alpine"
```

## 🏗️ Architecture

### Directory Structure
```
.github/
├── workflows/
│   ├── build-push.yaml              # Main workflow
│   ├── reusable-build-image.yml     # Reusable workflow
│   └── build-all-images.yml         # Example usage
└── .images/
    ├── Dockerfile.node              # Node.js Dockerfile
    ├── Dockerfile.python            # Python Dockerfile
    ├── post-install-node.sh         # Node.js post-install script
    └── post-install-python.sh       # Python post-install script
```

### Build Process
1. **Base Image**: Uses official Alpine-based Node.js/Python images
2. **Security Hardening**: Applies comprehensive security measures
3. **Package Installation**: Installs necessary packages with version pinning
4. **User Setup**: Creates non-root user and sets permissions
5. **Cleanup**: Removes package manager and unnecessary files
6. **Post-install**: Final security hardening and cleanup

## 🔒 Security Considerations

### What's Removed
- Package managers (apk, pip cache)
- Dangerous commands (curl, wget, nc, su, sudo)
- SUID/SGID binaries
- Unnecessary users and groups
- Temporary files and caches
- System files not needed in containers

### What's Protected
- System directories (`/bin`, `/etc`, `/lib`, `/sbin`, `/usr`)
- Application directory (`/app`)
- User permissions and ownership
- File permissions (750 for dirs, 640 for files)

### Runtime Security
- Non-root execution
- Minimal attack surface
- No package manager access
- Isolated application environment

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test with `./test-builds.sh`
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## ⚠️ Disclaimer

These images are designed for security but should be used as part of a comprehensive security strategy. Always:
- Keep base images updated
- Scan images for vulnerabilities
- Monitor runtime behavior
- Follow security best practices