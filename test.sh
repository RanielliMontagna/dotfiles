#!/usr/bin/env bash

###############################################################################
# test.sh
# 
# Quick test to verify all scripts are valid and can be executed
# Run this before committing changes
###############################################################################

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}Testing Dotfiles Project${NC}"
echo -e "${BLUE}========================================${NC}\n"

# Test 1: Check if all scripts exist
echo -e "${BLUE}Test 1: Checking if all scripts exist...${NC}"
SCRIPTS=(
    "bootstrap.sh"
    "scripts/01-essentials.sh"
    "scripts/02-shell.sh"
    "scripts/03-nodejs.sh"
    "scripts/04-docker.sh"
    "scripts/05-extras.sh"
)

for script in "${SCRIPTS[@]}"; do
    if [[ -f "$script" ]]; then
        echo -e "${GREEN}✓${NC} $script exists"
    else
        echo -e "${RED}✗${NC} $script NOT found"
        exit 1
    fi
done

# Test 2: Check if scripts are executable
echo -e "\n${BLUE}Test 2: Checking if scripts are executable...${NC}"
for script in "${SCRIPTS[@]}"; do
    if [[ -x "$script" ]]; then
        echo -e "${GREEN}✓${NC} $script is executable"
    else
        echo -e "${YELLOW}⚠${NC} $script is not executable (fixing...)"
        chmod +x "$script"
        echo -e "${GREEN}✓${NC} $script is now executable"
    fi
done

# Test 3: Check if dotfiles exist
echo -e "\n${BLUE}Test 3: Checking if dotfiles exist...${NC}"
DOTFILES=(
    "dotfiles/.zshrc"
    "dotfiles/.gitconfig"
    "dotfiles/.aliases"
)

for file in "${DOTFILES[@]}"; do
    if [[ -f "$file" ]]; then
        echo -e "${GREEN}✓${NC} $file exists"
    else
        echo -e "${RED}✗${NC} $file NOT found"
        exit 1
    fi
done

# Test 4: Check if documentation exists
echo -e "\n${BLUE}Test 4: Checking if documentation exists...${NC}"
DOCS=(
    "README.md"
    "PROJECT.md"
)

for doc in "${DOCS[@]}"; do
    if [[ -f "$doc" ]]; then
        echo -e "${GREEN}✓${NC} $doc exists"
    else
        echo -e "${RED}✗${NC} $doc NOT found"
        exit 1
    fi
done

# Test 5: Check for bash syntax errors
echo -e "\n${BLUE}Test 5: Checking for bash syntax errors...${NC}"
for script in "${SCRIPTS[@]}"; do
    if bash -n "$script" 2>/dev/null; then
        echo -e "${GREEN}✓${NC} $script has valid bash syntax"
    else
        echo -e "${RED}✗${NC} $script has syntax errors"
        bash -n "$script"
        exit 1
    fi
done

# Test 6: Check if scripts have proper shebang
echo -e "\n${BLUE}Test 6: Checking if scripts have proper shebang...${NC}"
for script in "${SCRIPTS[@]}"; do
    first_line=$(head -n 1 "$script")
    if [[ "$first_line" == "#!/usr/bin/env bash" ]] || [[ "$first_line" == "#!/bin/bash" ]]; then
        echo -e "${GREEN}✓${NC} $script has proper shebang"
    else
        echo -e "${YELLOW}⚠${NC} $script shebang: $first_line"
    fi
done

# Summary
echo -e "\n${BLUE}========================================${NC}"
echo -e "${GREEN}✓ All tests passed!${NC}"
echo -e "${BLUE}========================================${NC}\n"
echo -e "Project is ready to use!"
echo -e "Run ${YELLOW}bash bootstrap.sh${NC} to install on Zorin OS\n"
