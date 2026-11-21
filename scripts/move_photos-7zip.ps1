$SevenZip = "C:\Program Files\7-Zip\7z.exe"

$SourceFolder = "C:\My Pictures"
$Destination = "C:\My Pictures"
$ProcessedFolder = Join-Path $SourceFolder "processed"

New-Item -ItemType Directory -Force -Path $ProcessedFolder | Out-Null

Get-ChildItem $SourceFolder -Filter "takeout-*.zip" | ForEach-Object {

    $zip = $_.FullName

    Write-Host ""
    Write-Host "Processing $zip" -ForegroundColor Cyan

    & $SevenZip x `
        $zip `
        "Takeout\Google Photos\*" `
        "-o$Destination" `
        -aos `
        -y

    if ($LASTEXITCODE -eq 0) {
        Move-Item $zip $ProcessedFolder
        Write-Host "Moved to processed folder." -ForegroundColor Green
    }
    else {
        Write-Host "Extraction failed." -ForegroundColor Red
    }
}
