param(
	[Parameter(Mandatory = $true)]
	[string]$ExportPath,

	[string]$OutputPath
)

$ErrorActionPreference = 'Stop'

if ([string]::IsNullOrWhiteSpace($OutputPath)) {
	$OutputPath = Join-Path $PSScriptRoot '..\data\events.json'
}

if (-not (Test-Path -LiteralPath $ExportPath -PathType Leaf)) {
	throw "WordPress export not found: $ExportPath"
}

[xml]$document = Get-Content -LiteralPath $ExportPath -Raw
$namespaces = New-Object System.Xml.XmlNamespaceManager($document.NameTable)
$namespaces.AddNamespace('wp', 'http://wordpress.org/export/1.2/')

$events = foreach ($item in $document.SelectNodes('//item[wp:post_type="mec-events" and wp:status="publish"]', $namespaces)) {
	$metadata = @{}
	foreach ($entry in $item.SelectNodes('wp:postmeta', $namespaces)) {
		$key = $entry.SelectSingleNode('wp:meta_key', $namespaces).InnerText
		$value = $entry.SelectSingleNode('wp:meta_value', $namespaces).InnerText
		$metadata[$key] = $value
	}

	$startDate = $metadata['mec_start_date']
	if ($startDate -notmatch '^\d{4}-\d{2}-\d{2}$') { continue }

	$category = $item.SelectNodes('category[@domain="mec_category"]') |
		Select-Object -First 1 |
		ForEach-Object { $_.InnerText }
	$allDay = $metadata['mec_allday'] -eq '1'
	$startTime = if ($allDay) { $null } else { '{0:D2}:{1:D2}' -f [int]$metadata['mec_start_time_hour'], [int]$metadata['mec_start_time_minutes'] }
	$endTime = if ($allDay -or $metadata['mec_hide_end_time'] -eq '1') { $null } else { '{0:D2}:{1:D2}' -f [int]$metadata['mec_end_time_hour'], [int]$metadata['mec_end_time_minutes'] }

	[pscustomobject][ordered]@{
		id        = [int]$item.SelectSingleNode('wp:post_id', $namespaces).InnerText
		title     = $item.SelectSingleNode('title').InnerText
		startDate = $startDate
		endDate   = if ($metadata['mec_end_date'] -match '^\d{4}-\d{2}-\d{2}$') { $metadata['mec_end_date'] } else { $startDate }
		startTime = $startTime
		endTime   = $endTime
		allDay    = $allDay
		category  = $category
	}
}

$events = @($events | Sort-Object startDate, startTime, title)
$outputDirectory = Split-Path -Parent $OutputPath
New-Item -ItemType Directory -Force -Path $outputDirectory | Out-Null
$events | ConvertTo-Json -Depth 4 | Set-Content -LiteralPath $OutputPath -Encoding utf8
Write-Host "Exported $($events.Count) published MEC events to $OutputPath"
