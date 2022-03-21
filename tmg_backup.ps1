# Блок переменных для экспорта
# $gvExportDir - Путь к каталогу на файловом сервере в котором будут создаваться экспортируемые файлы
# $gvExportOptData - Константа определяющая опции экспорта. Подробнее http://msdn.microsoft.com/en-us/library/ms826700.aspx
# $gvPassword - Пароль для криптования информации об учетных данных, сохранённых в TMG
#
$gvBackupDir = "\\S11\e$\TMG\"
$gvExportDir = "$env:TEMP"
$gvExportOptData = 15
$gvPassword = "12345678"
#
# Блок переменных для удаления устаревших файлов экспорта
# $gvDelOldFiles - Признак необходимости удаления устаревших файлов
# $gvDelPeriod - Период хранения файлов экспорта в днях.
#
$gvDelOldFiles = $True
#$gvDelPeriod = 2
#
# Блок экспорта конфигураций всех обнаруженных массивов TMG
#
$vFPC = New-Object -comObject FPC.root
$vArrays = $vFPC.Arrays
Foreach ($vArray in $vArrays)
{
      write-host "Find array:" $vArray.Name
      $vDate = Get-Date -uformat "%Y%m%d_%H%M%S"
      $vFName = $vArray.Name + "_" + $vDate + ".xml"
      $vFPath = $gvExportDir + "\" + $vFName
      $vComment = "Exported by PowerShell"
      write-host "Export configuration for array:" $vArray.Name
      write-host "Path:" $vFPath
      $vArray.ExportToFile($vFPath, $gvExportOptData, $gvPassword, $vComment)
}

7z a -t7z $gvExportDir\$vFName.7z -mx=9 -mfb=64 -md=1024m -ms=on $vFPath
		
$secpasswd = ConvertTo-SecureString "SECRETPASSWORD" -AsPlainText -Force
$mycreds = New-Object System.Management.Automation.PSCredential ("example@example.com", $secpasswd)
$encoding = [System.Text.Encoding]::UTF8
Send-MailMessage -To "example@example.com" -Subject "TMG Backup" -Body $gvBackupDir -SmtpServer "smtp.example.com" -Credential $mycreds -Port 587 -UseSsl -from "example@example.com" -Encoding $encoding -Attachment $gvExportDir\$vFName.7z

Move-Item $gvExportDir\$vFName.7z $gvBackupDir
Remove-Item $gvExportDir\$vFName* -Force -Confirm:$false

If ($gvDelOldFiles = $True)
{
	$DaysBack =  (Get-Date).AddDays(-3)
Get-ChildItem -Path $gvBackupDir | Where-Object {$_.CreationTime -le $DaysBack} | Remove-Item -Verbose -Force
}