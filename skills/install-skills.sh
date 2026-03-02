#!/bin/bash
# Install FuelLift skills for Claude Code on macOS
# Run this after cloning the repo: bash skills/install-skills.sh

SKILLS_DIR="$(cd "$(dirname "$0")" && pwd)"
CLAUDE_COMMANDS="$HOME/.claude/commands"

# Create Claude commands directory if it doesn't exist
mkdir -p "$CLAUDE_COMMANDS"

# Also create project-level commands
PROJECT_ROOT="$(cd "$SKILLS_DIR/.." && pwd)"
PROJECT_COMMANDS="$PROJECT_ROOT/.claude/commands"
mkdir -p "$PROJECT_COMMANDS"

# Copy all skill .md files to project commands
for skill in "$SKILLS_DIR"/*.md; do
  if [ -f "$skill" ]; then
    filename=$(basename "$skill")
    cp "$skill" "$PROJECT_COMMANDS/$filename"
    echo "Installed: /$(basename "$filename" .md)"
  fi
done

echo ""
echo "FuelLift skills installed! Available commands:"
echo "  /build          - XcodeGen + build"
echo "  /test           - Run unit & UI tests"
echo "  /deploy         - Fastlane → TestFlight"
echo "  /sim            - Build & run in iOS Simulator"
echo "  /fix-build      - Diagnose & fix build errors"
echo "  /new-view       - Scaffold SwiftUI View + ViewModel"
echo "  /new-model      - Scaffold SwiftData @Model"
echo "  /new-service    - Create API service (singleton)"
echo "  /add-badge      - Add achievement badge"
echo "  /add-exercise   - Add exercises to library"
echo "  /project-health - Full project audit"
