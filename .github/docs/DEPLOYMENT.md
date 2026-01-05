# Documentation Deployment Guide

This guide explains how the documentation for Hydra-Yaci is deployed to GitHub Pages.

## 🌐 Live Documentation

The documentation is automatically deployed to: **https://kushal2060.github.io/hydra-yaci/**

## 📋 Prerequisites

Before the documentation can be deployed, ensure the following settings are configured in your GitHub repository:

1. **GitHub Pages must be enabled**:
   - Go to your repository on GitHub
   - Navigate to **Settings** → **Pages**
   - Under "Build and deployment":
     - **Source**: Select "GitHub Actions"
   
2. **Repository permissions**:
   - The workflow has appropriate permissions (already configured in the workflow file)

## 🚀 Automatic Deployment

The documentation is automatically deployed when:

- Changes are pushed to the `main` branch in the `.github/docs/` directory
- The deployment workflow (`.github/workflows/deploy-docs.yml`) is modified
- Manual deployment is triggered via "Run workflow" button in GitHub Actions

### Workflow Details

The deployment workflow:

1. **Triggers on**:
   - Push to `main` branch (when docs or workflow files change)
   - Manual workflow dispatch

2. **Build process**:
   - Checks out the repository
   - Sets up GitHub Pages
   - Builds the documentation using Jekyll
   - Uploads the built site as an artifact

3. **Deploy process**:
   - Deploys the artifact to GitHub Pages
   - Makes the site available at the GitHub Pages URL

## 🔧 Manual Deployment

To manually trigger a deployment:

1. Go to your repository on GitHub
2. Click on **Actions** tab
3. Select the "Deploy Documentation to GitHub Pages" workflow
4. Click **Run workflow** button
5. Select the `main` branch
6. Click **Run workflow**

## 📝 Documentation Structure

The documentation is located in `.github/docs/` and includes:

```
.github/docs/
├── _config.yml           # Jekyll configuration
├── index.md             # Main documentation page
├── README.md            # Documentation overview
├── getting-started.md   # Getting started guide
├── installation.md      # Installation instructions
├── configuration.md     # Configuration reference
├── usage.md             # Usage guide
├── api-reference.md     # API documentation
└── troubleshooting.md   # Troubleshooting guide
```

## 🎨 Theme and Styling

The documentation uses the **Cayman** Jekyll theme, configured in `_config.yml`:

```yaml
theme: jekyll-theme-cayman
title: Hydra-Yaci Documentation
description: Complete guide for using Hydra protocols with Yaci DevKit local network
```

## ✏️ Making Changes to Documentation

To update the documentation:

1. **Edit files** in `.github/docs/` directory
2. **Commit and push** to the `main` branch
3. **Automatic deployment** will trigger
4. **Wait for deployment** to complete (usually 1-2 minutes)
5. **Verify changes** at https://kushal2060.github.io/hydra-yaci/

### Local Preview

To preview documentation changes locally:

1. Install Jekyll:
   ```bash
   gem install bundler jekyll
   ```

2. Navigate to the docs directory:
   ```bash
   cd .github/docs
   ```

3. Create a `Gemfile` (if not exists):
   ```ruby
   source "https://rubygems.org"
   gem "github-pages", group: :jekyll_plugins
   ```

4. Install dependencies:
   ```bash
   bundle install
   ```

5. Serve the site locally:
   ```bash
   bundle exec jekyll serve
   ```

6. Open http://localhost:4000 in your browser

## 🔍 Troubleshooting Deployment

### Deployment Failed

If the deployment fails:

1. **Check the Actions tab** for error messages
2. **Verify Jekyll syntax** in markdown files
3. **Check `_config.yml`** for valid YAML syntax
4. **Review workflow logs** for specific errors

### Page Not Found (404)

If you get a 404 error after deployment:

1. **Wait a few minutes** - deployment can take time
2. **Check GitHub Pages settings** - ensure source is set to "GitHub Actions"
3. **Verify the workflow** completed successfully
4. **Check the repository visibility** - must be public for GitHub Pages (or have GitHub Pro for private repos)

### Changes Not Appearing

If changes don't appear on the site:

1. **Hard refresh** your browser (Ctrl+F5 or Cmd+Shift+R)
2. **Clear browser cache**
3. **Wait for deployment** to complete
4. **Check the Actions tab** to ensure deployment succeeded

## 📊 Monitoring Deployments

To monitor deployments:

1. Go to the **Actions** tab in your repository
2. Look for "Deploy Documentation to GitHub Pages" workflow runs
3. Click on a run to see detailed logs
4. Green checkmark = successful deployment
5. Red X = failed deployment (click for details)

## 🔒 Security

The workflow uses:

- **OIDC tokens** for secure deployment
- **Minimal permissions** (read contents, write pages)
- **Concurrency controls** to prevent conflicts

## 📚 Additional Resources

- [GitHub Pages Documentation](https://docs.github.com/en/pages)
- [Jekyll Documentation](https://jekyllrb.com/docs/)
- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [Jekyll Themes](https://pages.github.com/themes/)

## 🤝 Contributing to Documentation

When contributing to documentation:

1. Follow the existing structure and style
2. Test changes locally if possible
3. Submit a pull request with clear description
4. Wait for deployment to verify changes
5. Update this guide if adding new features

---

**Note**: This deployment setup is designed to be simple and automated. For most use cases, you won't need to modify the workflow file. Just edit the documentation and push to `main`!
