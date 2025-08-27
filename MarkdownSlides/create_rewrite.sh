#!/bin/bash
# MarkdownSlides Git History Rewriter
# Automatically rewrites commit history with better messages and recent dates

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_header() {
    echo -e "${BLUE}=== $1 ===${NC}"
}

# Check if we're in a git repository
if ! git rev-parse --git-dir > /dev/null 2>&1; then
    print_error "Not in a git repository. Please run this script from your project directory."
    exit 1
fi

# Create the script file
SCRIPT_FILE="rewrite_git_history.sh"
print_header "Creating Git History Rewrite Script"

cat > "$SCRIPT_FILE" << 'EOF'
#!/bin/bash
# Auto-generated Git History Rewrite Script for MarkdownSlides
# Generated on $(date)

set -e

echo "🚀 Starting automatic git history rewrite..."

# Create backup branch
echo "📦 Creating backup branch..."
git branch backup-before-rewrite-$(date +%Y%m%d-%H%M%S)

# Create a temporary file with the new commit messages
cat > /tmp/new_commit_messages.txt << 'COMMIT_MSGS'
feat: Initialize SwiftUI-based Markdown presentation app with basic project structure

feat: Add comprehensive image support with external URL handling and markdown syntax

feat: Implement slide templates system with reusable content patterns and layouts

feat: Add customizable footer with presentation title, logo support, and branding options

fix: Resolve font rendering issues and improve text clarity across all slide types

feat: Enhance title slides with improved typography, layout options, and visual hierarchy

feat: Add navigation buttons for intuitive slide navigation and presentation controls

feat: Implement scalable slide system with responsive layouts and adaptive sizing

feat: Add theme persistence and custom theme saving functionality with user preferences

feat: Implement comprehensive font customization with system font support and fallbacks

feat: Add basic syntax highlighting for markdown elements and code blocks

feat: Improve syntax highlighting with enhanced color schemes and better element detection

feat: Standardize slide separators using markdown horizontal rules (---) for consistency
COMMIT_MSGS

# Get all commits in reverse order
commits=$(git log --reverse --format="%H")

# Read new messages into array (compatible with all shells)
new_messages=()
while IFS= read -r line; do
    new_messages+=("$line")
done < /tmp/new_commit_messages.txt

# Counter for messages
msg_index=0

# Process each commit
while IFS= read -r commit_hash; do
    if [ ! -z "$commit_hash" ] && [ $msg_index -lt ${#new_messages[@]} ]; then
        echo "📝 Updating commit $commit_hash: ${new_messages[$msg_index]}"
        
        # Update commit message
        git filter-branch --msg-filter "
            if [ \$GIT_COMMIT = $commit_hash ]
            then
                echo '${new_messages[$msg_index]}'
            else
                cat
            fi
        " -- $commit_hash^..$commit_hash
        
        # Update commit date to be within last week (spread across 7 days)
        days_ago=$((6 - msg_index))
        
        if [[ "$OSTYPE" == "darwin"* ]]; then
            # macOS date command
            commit_date=$(date -v-${days_ago}d -u +"%Y-%m-%dT%H:%M:%S%z")
        else
            # Linux date command
            commit_date=$(date -d "$days_ago days ago" --iso-8601=seconds)
        fi
        
        echo "📅 Setting date to: $commit_date"
        
        git filter-branch --env-filter "
            if [ \$GIT_COMMIT = $commit_hash ]
            then
                export GIT_AUTHOR_DATE='$commit_date'
                export GIT_COMMITTER_DATE='$commit_date'
            fi
        " -- $commit_hash^..$commit_hash
        
        ((msg_index++))
    fi
done <<< "$commits"

# Clean up filter-branch refs
echo "🧹 Cleaning up temporary references..."
git for-each-ref --format="%(refname)" refs/original/ | xargs -n 1 git update-ref -d

# Remove temporary file
rm -f /tmp/new_commit_messages.txt

echo "✅ Git history rewrite complete!"
echo ""
echo "📊 Final git log:"
git log --oneline --graph --decorate -15

echo ""
echo "🎉 All done! Your git history has been rewritten with:"
echo "   - More descriptive and professional commit messages"
echo "   - Dates spread across the last week (7 days)"
echo "   - Backup branch created for safety"
echo ""
echo "💡 To restore original history: git reset --hard backup-before-rewrite-$(date +%Y%m%d)"
EOF

# Make the script executable
chmod +x "$SCRIPT_FILE"

print_status "Script created: $SCRIPT_FILE"
print_status "The script will automatically:"
echo "  • Create a backup branch"
echo "  • Rewrite all commit messages to be more descriptive and professional"
echo "  • Update all commit dates to be spread across the last week"
echo "  • Clean up temporary files"
echo ""

print_warning "Before running the script, make sure you have committed or stashed any current changes!"
echo ""

print_status "To run the script:"
echo "  ./$SCRIPT_FILE"
echo ""

print_status "The script will handle everything automatically - no manual intervention needed!"
echo ""

# Show current git status
print_header "Current Git Status"
git status --short

echo ""
print_status "Script ready! Run ./$SCRIPT_FILE when you're ready to rewrite your history."