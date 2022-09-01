while ($true) {
    $apitoken = "<PLEX_TOKEN>"
    $dvrkey = "<DVR_KEY>"
    $xmls = Get-ChildItem "/home/<USERNAME>/.xteve/data/*.xml"
    function Set-Hashes{
        $hashobjs = Get-FileHash -Algorithm SHA256 -Path $xmls
        $hashobjs | ConvertTo-Json | Out-File "/home/<USERNAME>/.xteve/data/config.json"
        Remove-Variable hashobjs
    }
    function Set-Xmls {
        foreach ($xml in $xmls){
            $cleanxml = Get-Content $xml | Where-Object { -not $_.Contains('src="https://tvguide2.cbsistatic.com/') }
            $cleanxml | Out-File "$($xml.FullName)"
            if (Test-Path "$xml.gz"){
                Remove-Item "$xml.gz"
                /usr/bin/gzip -k $xml.FullName
            }
        Remove-Variable cleanxml
        }
    }
    if (Test-Path "/home/<USERNAME>/.xteve/data/config.json"){
        $jsonobjs = ConvertFrom-Json (Get-Content -Raw "/home/<USERNAME>/.xteve/data/config.json")
        $count = 0
        foreach ($obj in $jsonobjs){
            $livehash = (Get-FileHash -Algorithm SHA256 -Path $obj.Path).Hash
            if ($livehash -ne $obj.Hash){
                $count = $count+1
            }
        }
        if ($count -ge 1){
            
            Write-Host "$count JSON hash(es) does not match live file hash, cleaning XML files and building config.json"
            Set-Xmls
            Set-Hashes

            Invoke-RestMethod -Method POST -Uri "http://127.0.0.1:32400/livetv/dvrs/$($dvrkey)/reloadGuide?X-Plex-Token=$($apitoken)"
        }
        else{
        Write-Host "JSON hashes match live hashes, exiting script"
        }
        Remove-Variable count, livehash, jsonobjs
    }
    else{

        Write-Host "No config file found. Cleaning XML files and creating config.json"
        Set-Xmls
        Set-Hashes

        Invoke-RestMethod -Method POST -Uri "http://127.0.0.1:32400/livetv/dvrs/$($dvrkey)/reloadGuide?X-Plex-Token=$($apitoken)"
    }
    Start-Sleep -Seconds 5
    [GC]::Collect()
}