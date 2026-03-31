# SulahMitra Static Workspace

Use `site/` as the clean, deployment-ready version of the website.

## Folder Guide

- `site/` - cleaned static bundle with local assets and static-friendly forms
- `scripts/build-clean-site.ps1` - rebuilds `site/` from the raw export in this workspace
- `scripts/sync-sulahmitra-static.ps1` - refreshes the raw export from the live site when needed
- project root pages and `wp-content/` - raw source export kept as source material

## Recommended Workflow

1. Make or refresh changes in the raw export files if needed.
2. Run `powershell -ExecutionPolicy Bypass -File .\scripts\build-clean-site.ps1`
3. Use the generated files inside `site/`

## Notes

- The contact and registration pages in `site/` no longer depend on the live WordPress backend.
- `site/` is the folder to upload, preview, or hand off.
