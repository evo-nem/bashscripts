#!/bin/bash

# Parent directory containing git repositories
PARENT_DIR="/home/lirim/tasks"

# Loop through each subdirectory in the parent directory
for REPO_DIR in "$PARENT_DIR"/*/; do
    if [ -d "$REPO_DIR" ]; then
        cd "$REPO_DIR"
        echo "--------------------------------------------------------"
        echo "in directory $REPO_DIR"
        echo "--------------------------------------------------------"
        # Check if it's a git repository
        if [ -d ".git" ]; then
            
            # Wildcard branch patterns
            BRANCH_PATTERNS=("nonprod-dev-deployment*" "nonprod-preprod-deployment*")
            
            for PATTERN in "${BRANCH_PATTERNS[@]}"; do
                # Find branches that match the pattern
                BRANCHES=$(git branch -r | grep -E "origin/${PATTERN}" | sed 's|origin/||')
                
                for BRANCH in $BRANCHES; do
                    # Checkout the branch
                    git checkout "$BRANCH"
                    echo "in branch $BRANCH ***************************************************"
                    
                    # File to edit
                    FILE="chatbot/08-deployment.yaml"
                    
                    if [ -f "$FILE" ]; then
                        # Check if initialDelaySeconds already exists
                        if ! grep -q "initialDelaySeconds:" "$FILE"; then
                            # Add the new line under readinessProbe:
                            echo "editing file $FILE *********************************************"
                            sed -i '/readinessProbe:/a \          initialDelaySeconds: 300' "$FILE"
                            
                            # Optional: stage the change
                            git add "$FILE"
                            
                            # Optional: commit the change
                            git commit -m "Readiness probe change"
                        else
                            echo "initialDelaySeconds already exists in $FILE"
                        fi
                    else
                        echo "File $FILE not found in $REPO_DIR"
                    fi
                done
            done
        else
            echo "$REPO_DIR is not a git repository"
        fi
        
        # Go back to the parent directory
        cd - > /dev/null
    fi
done
