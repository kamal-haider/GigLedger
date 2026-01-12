#!/bin/bash

# GitHub Labels Setup Script
# This script creates the standard labels for your project
#
# Usage:
#   ./setup-labels.sh <owner/repo>
#
# Example:
#   ./setup-labels.sh myusername/my-project
#
# Prerequisites:
#   - GitHub CLI (gh) installed and authenticated
#   - Write access to the repository

set -e

REPO="$1"

if [ -z "$REPO" ]; then
    echo "Usage: ./setup-labels.sh <owner/repo>"
    echo "Example: ./setup-labels.sh myusername/my-project"
    exit 1
fi

echo "Setting up labels for $REPO..."

# Function to create or update a label
create_label() {
    local name="$1"
    local description="$2"
    local color="$3"

    echo "  Creating label: $name"

    # Try to create the label, if it exists, update it
    gh label create "$name" \
        --description "$description" \
        --color "$color" \
        --repo "$REPO" \
        --force 2>/dev/null || true
}

echo ""
echo "Creating priority/status labels..."
create_label "ready-to-work" "Can be worked on immediately - no blockers" "0E8A16"
create_label "blocked" "Blocked by other issues or dependencies" "B60205"
create_label "blocked-by-pr" "Blocked by PR merge" "D93F0B"
create_label "post-mvp" "Pick up after core MVP features are complete" "E99695"
create_label "in-progress" "Currently being worked on" "FFA500"
create_label "user-config" "Requires user configuration (not code)" "FBCA04"

echo ""
echo "Creating category labels..."
create_label "bug" "Something isn't working" "d73a4a"
create_label "enhancement" "New feature or request" "a2eeef"
create_label "documentation" "Improvements or additions to documentation" "0075ca"
create_label "good first issue" "Good for newcomers" "7057ff"
create_label "help wanted" "Extra attention is needed" "008672"
create_label "question" "Further information is requested" "d876e3"
create_label "duplicate" "This issue or pull request already exists" "cfd3d7"
create_label "invalid" "This doesn't seem right" "e4e669"
create_label "wontfix" "This will not be worked on" "ffffff"

echo ""
echo "Creating area labels..."
create_label "frontend" "Frontend UI work" "1D76DB"
create_label "backend" "Backend work" "0052CC"
create_label "foundation" "Project foundation / bootstrap work" "0E8A16"
create_label "ui" "UI screens/components" "1D76DB"
create_label "core-feature" "Core/flagship feature" "5319E7"
create_label "analytics" "Analytics/charts" "5319E7"
create_label "pro-feature" "Pro-only feature" "5319E7"
create_label "monetization" "Monetization" "E99695"
create_label "subscription" "Subscriptions/paywall" "E99695"
create_label "performance" "Performance improvements" "0E8A16"
create_label "optimization" "Optimization" "0E8A16"
create_label "launch" "Launch preparation" "000000"
create_label "release" "Release" "000000"
create_label "testing" "Test coverage and quality" "6f42c1"
create_label "security" "Security-related issues" "B60205"
create_label "data-model" "Data model/schema" "BFDADC"
create_label "navigation" "Routing/navigation" "5319E7"

echo ""
echo "Creating feature labels (customize these for your project)..."
create_label "home" "Home screen" "C5DEF5"
create_label "auth" "Authentication" "C5DEF5"
create_label "onboarding" "Onboarding flow" "C5DEF5"
create_label "profile" "Profile/settings" "C5DEF5"

echo ""
echo "Done! Labels have been created for $REPO"
echo ""
echo "To add technology-specific labels, run commands like:"
echo "  gh label create 'flutter' --description 'Flutter implementation' --color '1D76DB' --repo $REPO"
echo "  gh label create 'firebase' --description 'Firebase integration' --color 'FF6F00' --repo $REPO"
echo ""
echo "To add more feature labels:"
echo "  gh label create 'feature-name' --description 'Feature description' --color 'C5DEF5' --repo $REPO"
