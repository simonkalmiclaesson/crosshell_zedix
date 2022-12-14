<#
  .SYNOPSIS
  Command for running included third-party games, add parameters by giving '-params' a string sepparated by semi colons with formatting <name>§colon§<value>
#>

param([alias("name")][string]$game,[string]$params,[switch]$list,[switch]$debug,[switch]$int)

#Settings
$singlesave = $true

# load api
. "$psscriptroot\.gamehub_assets\gamehub_api.ps1"

if ($list) {
  $files = get-childitem "$psscriptroot\.games\" -recurse
  foreach ($file in $files) {
    if ($file.mode -eq "-a---") {
      if ((split-path $file -extension) -eq ".ps1") {
        write-host $file.name -f darkyellow
      }
    }
  }
}

if ($game) {
  $files = get-childitem "$psscriptroot\.games\" -recurse
  foreach ($file in $files) {
    if ($file.mode -eq "-a---") {
      if ((split-path $file -extension) -eq ".ps1") {
        if ((split-path $file -leafbase) -eq "$game") {
          #$oldexecpol = get-executionpolicy
          #Set-executionpolicy bypass -scope CurrentUser
          $p = "$file"
          $name = $file.name
          $curpath = gl
          $pa = $p.replace($(split-path $p -leaf),"")
          cd $pa
          $data = gc .\$name
          if ("$debug" -eq "$true") {
            if ($data[0] -eq "#requires -version 2" -or $data[0] -eq "#requires -version 5.1") {
              if ($params) {
                $gamerunner = Start-Process powershell "$pa$name -debug -params '$params'" -passthru
              } else {
                $gamerunner = Start-Process powershell "$pa$name -debug" -passthru
              }
            } else {
              if ($params) {
                $gamerunner = Start-Process pwsh "$pa$name -debug -params '$params'" -passthru
              } else {
                $gamerunner = Start-Process pwsh "$pa$name -debug" -passthru
              }
            }
          } elseif ("$int" -eq "$true") {
            if ($data[0] -eq "#requires -version 2" -or $data[0] -eq "#requires -version 5.1") {
              if ($params) {
                powershell $pa$name -params "$params"
              } else {
                powershell $pa$name
              }
              #powershell $pa$name
              #pause
            } else {
              if ($params) {
                pwsh $pa$name -params "$params"
              } else {
                pwsh $pa$name
              }
            }
          } else {
            if ($data[0] -eq "#requires -version 2" -or $data[0] -eq "#requires -version 5.1") {
              if ($params) {
                $gamerunner = Start-Process powershell "$pa$name -params '$params'" -passthru
              } else {
                $gamerunner = Start-Process powershell $pa$name -passthru
              }
              #powershell $pa$name
              #pause
            } else {
              if ($params) {
                $gamerunner = Start-Process pwsh "$pa$name -params '$params'" -passthru
              } else {
                $gamerunner = Start-Process pwsh $pa$name -passthru
              }
            }
          }
          try {
            Wait-Process $gamerunner.Id
            gamehub_saveService_off
          }
          catch {}
          [string]$fn = "$game" + "_score.tmp"
          if ($singlesave -eq $true) { gamehub_singlesave "$fn" -abs }
          cd $curpath
          #$script:gobackcommand = "Set-executionpolicy $oldexecpol"
          break
        }
      }
    }
  }
}