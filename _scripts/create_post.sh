#!/bin/bash

# Source the templates
source "$(dirname "$0")/post_template.sh"

# Get current date in YYYY-MM-DD format
current_date=$(date +%Y-%m-%d)

# Function to slugify text (convert to URL-friendly format)
slugify() {
    echo "$1" | iconv -t ascii//TRANSLIT | sed -E 's/[^a-zA-Z0-9]+/-/g' | sed -E 's/^-+|-+$//g' | tr A-Z a-z
}

# Prompt for post details
read -p "Enter English title: " en_title
read -p "Enter Polish title: " pl_title
read -p "Enter English description: " en_description
read -p "Enter Polish description: " pl_description

# Generate URL-friendly permalink from English title
permalink=$(slugify "$en_title")

# Create filenames
en_filename="${current_date}-${permalink}.md"
pl_filename="${current_date}-$(slugify "$pl_title").md"

# Create posts directory if it doesn't exist
posts_dir="$(dirname "$0")/../_posts"
mkdir -p "$posts_dir"

# Generate English post
generate_en_template "$en_title" "$en_description" "$current_date" "$permalink" > "${posts_dir}/${en_filename}"

# Generate Polish post
generate_pl_template "$pl_title" "$pl_description" "$current_date" "$permalink" > "${posts_dir}/${pl_filename}"

echo "Created posts:"
echo "  - ${en_filename}"
echo "  - ${pl_filename}"
