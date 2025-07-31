#!/usr/bin/env bash
# GitHub Actions optimized build script with proper caching
set -eu

DIR="$(CDPATH='' cd -- "$(dirname -- "$0")" && pwd)"

# Check for cache restoration
if [ -f "$DIR/.build-cache/stage2-complete.marker" ]; then
    echo "✅ Found cached build stages"
    echo "📦 Restoring cached work directory..."
    
    # Extract cached stages if they exist
    if [ -f "$DIR/.build-cache/stages.tar.gz" ]; then
        tar -xzf "$DIR/.build-cache/stages.tar.gz" -C "$DIR"
        echo "✅ Restored work directory from cache"
    fi
    
    # For webhook triggers, skip base stages
    if [ "$GITHUB_EVENT_NAME" == "repository_dispatch" ]; then
        echo "🚀 Webhook trigger detected - enabling incremental build"
        export SKIP_STAGES="stage0 stage1 stage2"
        export INCREMENTAL=1
    fi
fi

# Run the regular build
if [ -f ./build-docker-fast.sh ] && [ "${INCREMENTAL:-0}" == "1" ]; then
    ./build-docker-fast.sh -i "$@"
else
    ./build-docker.sh "$@"
fi

# Save cache after successful build
if [ $? -eq 0 ]; then
    echo "💾 Saving build cache..."
    mkdir -p "$DIR/.build-cache"
    
    # Check if stage2 was completed
    if docker exec pigen_work test -f /pi-gen/work/stage2/EXPORT_IMAGE 2>/dev/null; then
        echo "📦 Extracting work directory from container for caching..."
        
        # Copy work directory from container
        docker cp pigen_work:/pi-gen/work "$DIR/work-tmp" || true
        
        # Create cache archive (only stages 0-2)
        if [ -d "$DIR/work-tmp" ]; then
            cd "$DIR/work-tmp"
            tar -czf "$DIR/.build-cache/stages.tar.gz" \
                --exclude="*/rootfs" \
                --exclude="*.img" \
                --exclude="*.log" \
                stage0 stage1 stage2 2>/dev/null || true
            cd "$DIR"
            rm -rf "$DIR/work-tmp"
            
            # Create marker file
            touch "$DIR/.build-cache/stage2-complete.marker"
            echo "✅ Cache saved successfully"
        fi
    fi
fi