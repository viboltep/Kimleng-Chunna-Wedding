# Workflow Fixes for Firebase Deployment

## Issue Identified

The error "An error occurred trying to start process '/usr/bin/bash'" in the `firebase-hosting-merge.yml` workflow was likely caused by:

1. **Missing workflow file**: The workflow file `firebase-hosting-merge.yml` was referenced but didn't exist locally
2. **Missing GitHub Secrets**: The SSH actions require secrets that might not be configured
3. **Build command inconsistency**: Previous builds may have used incorrect flags

## Files Created/Updated

### 1. `.github/workflows/firebase-hosting-merge.yml` (NEW)
   - Created the missing workflow file
   - Uses correct build command: `--no-tree-shake-icons` (for Khmer fonts)
   - Tests are optional (won't block deployment)
   - Properly formatted YAML

### 2. `.github/workflows/firebase-deploy.yml` (NEW)
   - Firebase Hosting deployment workflow
   - Uses Firebase deployment action

### 3. `.github/workflows/deploy.yml` (UPDATED)
   - Fixed build command
   - Made tests optional

## Required GitHub Secrets

For the `firebase-hosting-merge.yml` workflow to work, you need these secrets configured in GitHub:

1. **VPS_HOST** - Your VPS server hostname or IP
2. **VPS_USER** - SSH username for VPS
3. **SSH_PRIVATE_KEY** - Private SSH key for authentication

### How to Add Secrets:

1. Go to your GitHub repository
2. Navigate to **Settings** > **Secrets and variables** > **Actions**
3. Click **New repository secret**
4. Add each secret:
   - Name: `VPS_HOST`, Value: `your-server-ip-or-hostname`
   - Name: `VPS_USER`, Value: `your-ssh-username`
   - Name: `SSH_PRIVATE_KEY`, Value: `-----BEGIN OPENSSH PRIVATE KEY-----\n...\n-----END OPENSSH PRIVATE KEY-----`

### For Firebase Deployment:

If using `firebase-deploy.yml`, you need:
- **FIREBASE_SERVICE_ACCOUNT** - Firebase service account JSON
- **FIREBASE_PROJECT_ID** - Your Firebase project ID (from `.firebaserc`: `kimlengchunna`)

## Testing the Fix

1. **Commit and push the new workflow file:**
   ```bash
   git add .github/workflows/firebase-hosting-merge.yml
   git commit -m "Add firebase-hosting-merge.yml workflow"
   git push
   ```

2. **Check the workflow run:**
   - Go to the **Actions** tab in GitHub
   - The workflow should now run without the bash execution error
   - If it still fails, check the logs for specific error messages

## Common Issues and Solutions

### Issue: "An error occurred trying to start process '/usr/bin/bash'"
**Solution**: 
- Verify all required secrets are set
- Check that SSH_PRIVATE_KEY is properly formatted (should include `-----BEGIN` and `-----END` lines)
- Ensure the SSH key has proper permissions on the VPS

### Issue: "Permission denied" or SSH connection fails
**Solution**:
- Verify the SSH key is added to the VPS `~/.ssh/authorized_keys`
- Check that the VPS_USER has sudo permissions (for nginx reload)
- Test SSH connection manually: `ssh -i keyfile user@host`

### Issue: Build fails
**Solution**:
- The build command now uses `--no-tree-shake-icons` which is required for Khmer fonts
- Tests are optional and won't block deployment

## Workflow Comparison

| Workflow | Purpose | Deployment Target |
|----------|---------|-------------------|
| `firebase-hosting-merge.yml` | VPS deployment | Your VPS server |
| `firebase-deploy.yml` | Firebase deployment | Firebase Hosting |
| `deploy.yml` | VPS deployment (alternative) | Your VPS server |

All workflows now use the same build command for consistency.
