# CI/CD Setup Guide

## Overview
This document provides instructions for setting up and configuring the Continuous Integration and Continuous Delivery pipeline for CarInspectinator.

## Prerequisites

- GitHub repository
- GitHub Actions enabled
- Xcode 16.0+ installed (for local testing)
- visionOS SDK

## CI Pipeline Components

### 1. Main CI Workflow (`.github/workflows/ci.yml`)

**Triggers**:
- Push to `main` or `develop` branches
- Pull requests to `main` or `develop`
- Manual workflow dispatch

**Jobs**:

#### `build-and-test`
- Builds the application
- Runs all unit and integration tests
- Generates code coverage report
- **Enforces 70% minimum coverage**
- Uploads coverage artifacts
- Comments coverage on PRs

#### `lint`
- Runs SwiftLint
- Reports code style issues
- Continues on error (informational)

#### `build-check`
- Verifies the application builds successfully
- Catches compilation errors early

### 2. Coverage Report Workflow (`.github/workflows/coverage-report.yml`)

**Triggers**:
- Push to `main` branch
- Manual workflow dispatch

**Features**:
- Generates detailed coverage report
- Creates coverage badge (requires setup)
- Commits report to `test-reports/` directory
- Tracks coverage trends over time

## Setup Instructions

### Step 1: Enable GitHub Actions

1. Go to your repository on GitHub
2. Navigate to Settings → Actions → General
3. Ensure "Allow all actions and reusable workflows" is selected
4. Save changes

### Step 2: Configure Repository Secrets (Optional)

For coverage badge generation:

1. Create a personal access token with `gist` scope
2. Add it as repository secret:
   - Go to Settings → Secrets and variables → Actions
   - Click "New repository secret"
   - Name: `GIST_SECRET`
   - Value: Your personal access token

### Step 3: Create Coverage Badge Gist (Optional)

1. Go to https://gist.github.com
2. Create a new gist named `coverage-badge.json`
3. Copy the gist ID from the URL
4. Update `.github/workflows/coverage-report.yml`:
   ```yaml
   gistID: YOUR_GIST_ID_HERE
   ```

### Step 4: Test the Pipeline

1. Push a commit to trigger the workflow:
   ```bash
   git add .
   git commit -m "Test CI pipeline"
   git push origin main
   ```

2. Monitor the workflow:
   - Go to Actions tab in GitHub
   - Watch the workflow execution
   - Check for any errors

### Step 5: Verify Coverage Enforcement

The pipeline will fail if code coverage drops below 70%. Test this by:

1. Removing some tests
2. Push to a feature branch
3. Create a pull request
4. Observe the CI failure
5. Restore the tests

## Workflow Files Explanation

### Main CI Workflow

```yaml
name: CI

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main, develop ]

jobs:
  build-and-test:
    runs-on: macos-14
    steps:
      - Checkout code
      - Setup Xcode
      - Build for testing
      - Run tests
      - Generate coverage
      - Check 70% threshold ← ENFORCED
      - Upload artifacts
      - Comment on PR
```

### Coverage Check Logic

```bash
COVERAGE=$(xcrun xccov view --report --json ...)
if [ $COVERAGE_INT -lt 70 ]; then
  echo "❌ Coverage below 70% threshold"
  exit 1  # Fail the build
fi
```

## Local Testing

### Run Tests Locally

```bash
cd vision-pro

# Run all tests
xcodebuild test \
  -project CarInspectinator.xcodeproj \
  -scheme CarInspectinator \
  -destination 'platform=visionOS Simulator,name=Apple Vision Pro' \
  -enableCodeCoverage YES
```

### Check Coverage Locally

```bash
# Generate coverage report
xcrun xccov view --report DerivedData/Logs/Test/*.xcresult

# Check if above 70%
COVERAGE=$(xcrun xccov view --report --json DerivedData/Logs/Test/*.xcresult | \
  python3 -c "import sys, json; print(json.load(sys.stdin)['lineCoverage'])")
echo "Coverage: $COVERAGE%"
```

### Simulate CI Environment

```bash
# Clean build
rm -rf ~/Library/Developer/Xcode/DerivedData

# Run exactly as CI does
xcodebuild clean build-for-testing test-without-building \
  -project CarInspectinator.xcodeproj \
  -scheme CarInspectinator \
  -destination 'platform=visionOS Simulator,name=Apple Vision Pro' \
  -enableCodeCoverage YES
```

## Monitoring and Maintenance

### Viewing Workflow Runs

1. Go to Actions tab in GitHub
2. Select a workflow run
3. Click on a job to see logs
4. Download artifacts for detailed reports

### Common Issues

#### Issue: Tests Timeout
**Solution**: Increase timeout in workflow:
```yaml
timeout-minutes: 30  # Default is 10
```

#### Issue: Simulator Not Found
**Solution**: Update simulator name in workflow:
```yaml
env:
  VISIONOS_SIMULATOR: 'Apple Vision Pro'
```

#### Issue: Coverage Not Generated
**Solution**: Verify `-enableCodeCoverage YES` flag is present

#### Issue: Coverage Below 70%
**Solution**: Add more tests until coverage reaches 70%+

### Updating Xcode Version

When a new Xcode version is released:

1. Update `XCODE_VERSION` in workflow:
   ```yaml
   env:
     XCODE_VERSION: '16.0'  # Update this
   ```

2. Test locally with new Xcode first
3. Push and monitor CI

**Note**: The project uses `objectVersion = 77` (Xcode 16 format), so Xcode 16.0+ is required.

## Coverage Trends

Track coverage over time:

```bash
# View coverage history
cd test-reports
git log --oneline --all --decorate --graph -- coverage.txt

# Compare coverage between commits
git diff HEAD~1:test-reports/coverage.txt test-reports/coverage.txt
```

## Badge Setup

### Adding Coverage Badge to README

1. Generate badge using shields.io:
   ```markdown
   ![Coverage](https://img.shields.io/badge/coverage-XX%25-brightgreen)
   ```

2. Or use dynamic badge with Gist:
   ```markdown
   ![Coverage](https://img.shields.io/endpoint?url=https://gist.githubusercontent.com/YOUR_USERNAME/YOUR_GIST_ID/raw/coverage-badge.json)
   ```

### Adding Workflow Status Badge

```markdown
![CI](https://github.com/YOUR_USERNAME/CarInspectinator/workflows/CI/badge.svg)
```

## Performance Optimization

### Caching

The workflow caches derived data to speed up builds:

```yaml
- name: Cache derived data
  uses: actions/cache@v3
  with:
    path: ~/Library/Developer/Xcode/DerivedData
    key: ${{ runner.os }}-derived-data-${{ hashFiles('**/*.xcodeproj') }}
```

### Parallel Execution

Tests can be run in parallel for faster execution:

```yaml
-parallel-testing-enabled YES
-maximum-parallel-testing-workers 4
```

## Security

### Secrets Management

Never commit sensitive data. Use GitHub Secrets for:
- API keys
- Access tokens
- Passwords
- Certificates

### Pull Request Security

The workflow is configured to run safely on PRs from forks:
- Secrets are not exposed to fork PRs
- Write permissions are restricted
- Coverage comments use GITHUB_TOKEN

## Notifications

### Slack Integration (Optional)

Add Slack notifications:

```yaml
- name: Notify Slack
  if: failure()
  uses: 8398a7/action-slack@v3
  with:
    status: ${{ job.status }}
    webhook_url: ${{ secrets.SLACK_WEBHOOK }}
```

### Email Notifications

GitHub sends email notifications by default for:
- Failed workflows
- Fixed workflows
- Workflow disabled

Configure in: Settings → Notifications

## Best Practices

1. **Always run tests locally before pushing**
2. **Keep coverage above 70%**
3. **Fix failing tests immediately**
4. **Review coverage reports in PRs**
5. **Don't skip CI checks**
6. **Update tests when changing code**

## Troubleshooting Commands

```bash
# View workflow logs
gh run list
gh run view RUN_ID --log

# Re-run failed workflows
gh run rerun RUN_ID

# Download artifacts
gh run download RUN_ID

# Cancel running workflow
gh run cancel RUN_ID
```

## Future Enhancements

### Planned Improvements

1. **Matrix Testing**
   - Test on multiple Xcode versions
   - Test on different simulators

2. **Performance Testing**
   - Add performance benchmarks
   - Track performance regressions

3. **Deployment Automation**
   - Automatic TestFlight uploads
   - App Store Connect integration

4. **Advanced Coverage**
   - Per-file coverage targets
   - Coverage diff in PRs
   - Historical coverage tracking

## Resources

- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [Xcode Build Settings](https://developer.apple.com/documentation/xcode/build-settings-reference)
- [xcodebuild Man Page](https://keith.github.io/xcode-man-pages/xcodebuild.1.html)
- [xcov Tool](https://github.com/fastlane-community/xcov)

## Summary

✅ **CI/CD Pipeline Features**:
- Automated testing on every push
- Code coverage measurement
- 70% coverage threshold enforcement
- Pull request comments
- Test result artifacts
- Multiple jobs (test, lint, build)
- Caching for performance

✅ **Setup Complete**:
- Workflow files created
- Coverage reporting configured
- Documentation provided
- Ready to use!

The CI/CD pipeline is now fully configured and ready to ensure code quality and maintainability throughout the development process.

