# Document Sync Rule

## Purpose

Ensure related documentation is updated whenever code or design changes are made.

## Rules

### When Documentation Updates Are Required

- **Script changes**: Update README.md or DOCKER_SANDBOX.md when sandbox behavior changes
- **Security changes**: Update the security features section when restrictions are added or removed
- **Dockerfile changes**: Update DOCKER_SANDBOX.md when the image build process changes
- **New sandbox variant**: Update README.md to list the new variant with installation instructions
- **Config changes**: Update setup guides when environment variables or mount paths change

### Target Documents

Check and update these files if they exist:

- `README.md`
- `DOCKER_SANDBOX.md`

### Completion Checklist

Before finishing work, verify:

1. Are there documents related to this change?
2. If so, do they reflect the current state?
3. If new features or concepts were added, should new documentation be created?
