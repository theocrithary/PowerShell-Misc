# Setup variables

$TargetFolder = "D:\IIS\inventory\data"
$PurgeZIP = 15		# any .ZIP files older than x days will be purged
$PurgeFile = 2		# any files of 'FileType' older than x days will be purged
$ArchiveDays = 1	# anything older than x days will be archived to a zip file
$FileType = "*.htm"
$LogFile = "D:\VMware_Team\Scripts\Cleanup_script.log"
 

# Delete existing log file

if (Test-Path $LogFile)
{
   remove-item $LogFile
}

# Perform actions

if (Test-Path $TargetFolder)
{
 $Now = Get-Date

 foreach ($i in Get-ChildItem $TargetFolder\* -Include $FileType)
 {
    if ($i.LastWriteTime -lt $Now.AddDays(-$ArchiveDays))
    {
        echo "archiving....." $i.FullName | out-file -Append $LogFile
	$zipfilename = $i.FullName.Substring(40,10)
	$path = $TargetFolder+"\"+$zipfilename+".zip"
	if(-not (test-path($path)))
	{
	   set-content $path ("PK" + [char]5 + [char]6 + ("$([char]0)" * 18))
	   (dir $path).IsReadOnly = $false	
	}
	$shellApplication = new-object -com shell.application
	$zipFile = $shellApplication.NameSpace($path)
	$zipFile.CopyHere($i.FullName)
	start-sleep -milliseconds 500
    }  
    if ($i.LastWriteTime -lt $Now.AddDays(-$PurgeFile))
    {
        echo "deleting....." $i.FullName | out-file -Append $LogFile 
	remove-item $i.FullName  
    }
 }
 foreach ($i in Get-ChildItem $TargetFolder\* -Include "*.zip")
 {
    if ($i.LastWriteTime -lt $Now.AddDays(-$PurgeZIP))
    {
  	echo "deleting....." $i.FullName | out-file -Append $LogFile 
	remove-item $i.FullName  
    }
 }
}