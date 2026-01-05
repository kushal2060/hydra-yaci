# GitHub Pages Setup Instructions

This document provides step-by-step instructions to enable GitHub Pages for your repository and deploy the documentation.

## 📋 Overview

Your repository now has:
- ✅ GitHub Actions workflow (`.github/workflows/deploy-docs.yml`)
- ✅ Jekyll-configured documentation (`.github/docs/`)
- ✅ Deployment guide (`.github/docs/DEPLOYMENT.md`)
- ✅ Updated README with documentation links

## 🚀 Steps to Enable GitHub Pages

Follow these steps to deploy your documentation:

### Step 1: Enable GitHub Pages in Repository Settings

1. **Navigate to your repository** on GitHub:
   ```
   https://github.com/kushal2060/hydra-yaci
   ```

2. **Go to Settings**:
   - Click on the **Settings** tab (top right of your repository page)

3. **Navigate to Pages**:
   - In the left sidebar, scroll down and click on **Pages**

4. **Configure the source**:
   - Under "Build and deployment"
   - **Source**: Select **GitHub Actions** from the dropdown
   
   ![GitHub Pages Source Setting](https://docs.github.com/assets/cb-47267/mw-1440/images/help/pages/github-actions-source.webp)

5. **Save** (if there's a save button, otherwise the setting is applied automatically)

### Step 2: Merge the Pull Request

1. **Navigate to the Pull Request**:
   - Go to the **Pull Requests** tab
   - Find the PR titled something like "Deploy GitHub Pages documentation"

2. **Review the changes**:
   - Review the workflow file and documentation updates
   - Ensure all changes look correct

3. **Merge the PR** to the `main` branch:
   - Click **Merge pull request**
   - Click **Confirm merge**

### Step 3: Wait for Deployment

1. **Monitor the deployment**:
   - Go to the **Actions** tab in your repository
   - You should see a workflow run called "Deploy Documentation to GitHub Pages"
   - Click on it to see the progress

2. **Wait for completion**:
   - The workflow typically takes 1-2 minutes to complete
   - Green checkmark ✓ = Success
   - Red X = Failed (check logs for errors)

### Step 4: Verify the Documentation Site

1. **Access your documentation**:
   - Open your browser and go to:
     ```
     https://kushal2060.github.io/hydra-yaci/
     ```

2. **Verify the content**:
   - You should see your documentation homepage
   - Navigate through different pages to ensure they load correctly
   - Check that all links work properly

## 🔧 Troubleshooting

### If Pages are not deploying:

1. **Check repository visibility**:
   - GitHub Pages requires the repository to be **public** (or GitHub Pro/Enterprise for private repos)
   - Go to Settings → scroll to bottom → check "Repository visibility"

2. **Verify workflow permissions**:
   - Go to Settings → Actions → General
   - Scroll to "Workflow permissions"
   - Ensure "Read and write permissions" is selected
   - Check "Allow GitHub Actions to create and approve pull requests"
   - Click **Save**

3. **Check workflow status**:
   - Go to Actions tab
   - Look for failed workflow runs
   - Click on failed runs to see error messages

4. **Re-run the workflow**:
   - Go to Actions tab
   - Click on "Deploy Documentation to GitHub Pages"
   - Click "Run workflow" button
   - Select `main` branch
   - Click "Run workflow"

### If you get a 404 error:

1. **Wait a few minutes** - initial deployment can take time
2. **Hard refresh** your browser (Ctrl+F5 or Cmd+Shift+R)
3. **Check GitHub Pages settings** - ensure source is "GitHub Actions"
4. **Verify the workflow completed** successfully in the Actions tab

### If changes aren't appearing:

1. **Check that you merged to `main`** branch
2. **Verify workflow triggered** (Actions tab)
3. **Wait for deployment** to complete
4. **Clear browser cache** or try incognito/private mode

## 📝 Making Updates to Documentation

Once deployed, you can update documentation by:

1. **Edit files** in `.github/docs/` directory
2. **Commit and push** to `main` branch
3. **Automatic deployment** will trigger
4. **Wait 1-2 minutes** for changes to appear

See [DEPLOYMENT.md](.github/docs/DEPLOYMENT.md) for detailed information about managing the documentation.

## 🎯 Quick Test

After setup, try this quick test:

1. **Edit** `.github/docs/index.md`
2. **Add** a small change (e.g., update the description)
3. **Commit and push** to `main`
4. **Go to Actions tab** and watch the deployment
5. **Refresh** your documentation site to see the change

## 📚 Additional Information

### Workflow Details

The workflow (`.github/workflows/deploy-docs.yml`):
- **Triggers on**: Push to `main` (when docs change)
- **Builds**: Using Jekyll
- **Deploys**: To GitHub Pages
- **Permissions**: Uses OIDC tokens for secure deployment

### Documentation Structure

```
.github/docs/
├── _config.yml           # Jekyll configuration (theme, title, etc.)
├── index.md             # Homepage
├── README.md            # Documentation overview
├── DEPLOYMENT.md        # This deployment guide
├── getting-started.md   # Getting started guide
├── installation.md      # Installation instructions
├── configuration.md     # Configuration reference
├── usage.md            # Usage guide
├── api-reference.md    # API documentation
└── troubleshooting.md  # Troubleshooting guide
```

### Theme

The documentation uses the **Cayman** theme:
- Clean, modern design
- Responsive (mobile-friendly)
- GitHub-style navigation
- Syntax highlighting for code blocks

## ✅ Checklist

Use this checklist to ensure everything is set up correctly:

- [ ] Repository is public (or you have GitHub Pro)
- [ ] GitHub Pages is enabled with source set to "GitHub Actions"
- [ ] Pull request is merged to `main` branch
- [ ] Workflow has run successfully (green checkmark in Actions tab)
- [ ] Documentation site is accessible at https://kushal2060.github.io/hydra-yaci/
- [ ] All documentation pages load correctly
- [ ] Navigation links work between pages
- [ ] Theme is applied correctly

## 🎉 Success!

Once all steps are complete, your documentation will be live at:

**https://kushal2060.github.io/hydra-yaci/**

You can now share this link with users, include it in your README, and it will automatically update whenever you push changes to the documentation!

## 💡 Tips

- **Bookmark** the documentation URL for quick access
- **Link to specific pages** like `https://kushal2060.github.io/hydra-yaci/getting-started.html`
- **Monitor deployments** in the Actions tab
- **Test locally** before pushing (see DEPLOYMENT.md for local preview setup)
- **Keep documentation updated** as you make changes to the project

---

**Need Help?**

- Check [DEPLOYMENT.md](.github/docs/DEPLOYMENT.md) for more details
- Review [GitHub Pages documentation](https://docs.github.com/en/pages)
- Check the [Actions tab](https://github.com/kushal2060/hydra-yaci/actions) for deployment logs
- Open an issue if you encounter problems
