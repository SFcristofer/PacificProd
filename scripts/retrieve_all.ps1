$ErrorActionPreference = "Stop"

for ($i=1; $i -le 14; $i++) {
    Write-Host "Retrieving chunk $i of 14 (manifest/package_$i.xml)..."
    sf project retrieve start -x manifest/package_$i.xml
    if ($LASTEXITCODE -ne 0) {
        Write-Host "Error retrieving chunk $i. Continuing to next..."
    }
}
Write-Host "Finished retrieving all chunks."
