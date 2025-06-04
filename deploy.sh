#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Print header
echo -e "${BLUE}"
echo "=================================================="
echo "🚀 VIBE FACTORY - GitHub Pages Deploy Script"
echo "=================================================="
echo -e "${NC}"

# Check if we're in a git repository
if [ ! -d ".git" ]; then
    print_error "This directory is not a git repository!"
    exit 1
fi

# Check git status
print_status "Checking git status..."
git status --porcelain

# Add the main files
print_status "Adding main files to git..."
git add index.html script.js styles.css

# Check if files were added
if [ $? -eq 0 ]; then
    print_success "Files added successfully!"
else
    print_error "Failed to add files to git!"
    exit 1
fi

# Show what will be committed
echo ""
print_status "Files staged for commit:"
git diff --cached --name-only

# Ask for commit message
echo ""
echo -e "${YELLOW}Enter your commit message:${NC}"
read -p "💬 " commit_message

# Check if commit message is not empty
if [ -z "$commit_message" ]; then
    print_warning "No commit message provided. Using default message."
    commit_message="Update landing page files"
fi

# Make the commit
print_status "Creating commit with message: '$commit_message'"
git commit -m "$commit_message"

if [ $? -eq 0 ]; then
    print_success "Commit created successfully!"
else
    print_error "Failed to create commit!"
    exit 1
fi

# Check current branch
current_branch=$(git rev-parse --abbrev-ref HEAD)
print_status "Current branch: $current_branch"

# Push to repository
print_status "Pushing changes to origin/$current_branch..."
git push origin $current_branch

if [ $? -eq 0 ]; then
    print_success "Changes pushed successfully!"
else
    print_error "Failed to push changes!"
    exit 1
fi

# Get repository URL for GitHub Pages
repo_url=$(git config --get remote.origin.url)
if [[ $repo_url == *"github.com"* ]]; then
    # Extract repository name
    repo_name=$(basename -s .git $repo_url)
    username=$(dirname $repo_url | xargs basename)
    
    # Remove .git suffix if present and handle different URL formats
    if [[ $repo_url == https://* ]]; then
        username=$(echo $repo_url | sed 's|https://github.com/||' | cut -d'/' -f1)
    elif [[ $repo_url == git@* ]]; then
        username=$(echo $repo_url | sed 's|git@github.com:||' | cut -d'/' -f1)
    fi
    
    github_pages_url="https://${username}.github.io/${repo_name}"
    
    echo ""
    print_success "🎉 Deployment completed!"
    echo ""
    echo -e "${GREEN}Your site will be available at:${NC}"
    echo -e "${BLUE}🌐 $github_pages_url${NC}"
    echo ""
    print_warning "Note: GitHub Pages may take a few minutes to update."
    print_status "You can check the deployment status in your repository's 'Actions' tab."
else
    print_warning "Could not determine GitHub Pages URL. Make sure this is a GitHub repository."
fi

echo ""
echo -e "${GREEN}✅ All done! Your Vibe Factory landing page has been updated!${NC}"
echo -e "${BLUE}=================================================="
echo "🚀 Ready to help more startups build their MVPs!"
echo "==================================================${NC}" 