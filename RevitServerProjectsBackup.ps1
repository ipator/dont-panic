<#
.SYNOPSIS
  Script for backup Autodesk Revit Server
.DESCRIPTION
  Backup Autodesk Revit Server projects and store zipped
.NOTES
  Version:        1.0
  Author:         ipator
  Creation Date:  05.12.2019
  Purpose/Change: Initial script development
#>

# The path where Revit stores projects
$RevitProjectsPath = "E:\Projects\"
# The path through which backups will be stored.
$BackupPath = "E:\BCKP\"
# The path through which periodic backups will be stored.
$IncrementPath = "E:\INCR\"
# Temporary folder
$BackupPathTmp = "E:\TMP\"
# The path to RevitServerTool.exe
$Command = "C:\Program Files\Autodesk\Revit Server 2019\Tools\RevitServerToolCommand\RevitServerTool.exe"
# The ip-address of revit server
$RevitServerIp = "192.168.2.81"

$Projects = Get-ChildItem -Recurse -Force $RevitProjectsPath -ErrorAction SilentlyContinue | Where-Object { ($_.PSIsContainer -eq $true) -and  ( $_.Name -like "*.rvt") } | Select-Object Name,FullName

if(!(Test-Path -Path $BackupPath )) { New-Item -ItemType directory -Path $BackupPath }
foreach($P in $Projects)
{
	$tmp=$P.FullName.Replace($RevitProjectsPath,"")
	$Params = 'createLocalRVT "{0}" -s {1} -d {2} -o' -f $tmp,$RevitServerIp,$BackupPathTmp
	$PRMS = $Params.Split(" ")
	& "$Command" $PRMS | Out-Null
	$BackupProjectFolder = '{0}{1}' -f $BackupPath,$tmp.TrimEnd($P.Name)
	if (!(Test-Path -Path $BackupProjectFolder )) { New-Item -ItemType directory -Path $BackupProjectFolder }
	Move-Item -Path ('{0}{1}' -f $BackupPathTmp,$P.Name) -Destination $BackupProjectFolder -Force
	if ((Test-Path -Path $BackupPathTmp )) { Remove-Item -Path $BackupPathTmp }
}
$filename="$(get-date -f yyyy-MM-dd_HH-mm-s).zip"
$destination = "{0}{1}" -f $IncrementPath,$filename
Add-Type -assembly "system.io.compression.filesystem"
[io.compression.zipfile]::CreateFromDirectory($BackupPath, $destination) 
