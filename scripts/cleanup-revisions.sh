#!/bin/bash

# Clean up old Cloud Run revisions to free quota
# Keeps the 2 most recent revisions for each service

PROJECT="inkwell-alpha"
REGION="us-central1"

echo "🧹 Cleaning up old Cloud Run revisions..."
echo ""

# Get all services
services=$(gcloud run services list --project=$PROJECT --region=$REGION --format="value(name)")

for service in $services; do
  echo "📦 Processing: $service"
  
  # Get revisions for this service, sorted newest first, skip first 2
  old_revisions=$(gcloud run revisions list \
    --service=$service \
    --project=$PROJECT \
    --region=$REGION \
    --format="value(name)" \
    --sort-by="~creationTimestamp" 2>/dev/null | tail -n +3)
  
  count=$(echo "$old_revisions" | grep -c . || echo 0)
  
  if [ "$count" -gt 0 ] && [ -n "$old_revisions" ]; then
    echo "   Deleting $count old revisions..."
    for rev in $old_revisions; do
      gcloud run revisions delete "$rev" \
        --project=$PROJECT \
        --region=$REGION \
        --quiet 2>/dev/null && echo "   ✓ Deleted $rev" || echo "   ⚠ Skipped $rev (in use)"
    done
  else
    echo "   ✓ Already clean"
  fi
done

echo ""
echo "✅ Cleanup complete!"

# Show remaining count
remaining=$(gcloud run revisions list --project=$PROJECT --region=$REGION --format="value(name)" | wc -l)
echo "📊 Remaining revisions: $remaining"
