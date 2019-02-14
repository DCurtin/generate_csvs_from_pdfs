
#parameters
#config file
#load values from that
#get config path from command

param (
    [string]$conf_file='.\settings.conf',
    [string]$file='C:\Users\dcurtin\Desktop\5498_doc.csv',
    [string]$AvailableInPortal='FALSE',
    [string]$description='This substitute 5498 is not final and may be subject to change',
    [string]$todays_date = (Get-Date -UFormat '%m/%d/%Y'),
    [string]$doc_name = (Get-Date -UFormat '%Y-%m-%d') + ' Tax Document',
    [string]$doc_type = 'Tax Document'
    #[string]$h='',
    #[string]$help=''
)

if($args[0] -eq '-h')
{
    Write-Host 'in help'
}

if(test-path $conf_file)
{
    Get-Content .\thing_file | %{
        $kv_pair=($_-split'=')
        if(kv_pair[0] -eq file)
        {
            $file=kv_pair[1]
        }
        
    }
}

return 0


#
echo '' > $file
Clear-Content $file
$csv_file_array=@()
$table = Import-Csv .\accounts_2_13_2019.csv

#generate hash table
Write-Host "Generating Hash table, may take a few minutes"
$HashTable=@{}
foreach($r in $table)
{
    $HashTable[$r.NAME.PadLeft(7,'0')]=$r.ID
}
Write-Host "Hash Table generated"

#get number of files to print out progress
$total_files = (Get-ChildItem '*.pdf').count
$count = 0

Get-ChildItem '*.pdf' | % {

    $count = $count + 1
    if(($count % 100 -eq 0) -or ($count -eq $total_files))
    {
        Write-Host $count out of $total_files completed 
    }

    if($_.FullName -match '\d{7}')
    {
        Write-Host $_.BaseName
        $id = $HashTable[$matches[0]]
        $csv_file_array += New-Object PSObject -Property @{'ACCOUNT ID'=$id; 'ACCOUNT NAME'=$matches[0]; 'DESCRIPTION'=$description; 'Content Type'='application/pdf'; 'DOC TYPE'=$doc_type; 'DOC DATE'=$todays_date; 'DOC NAME'=$doc_name;' AVAILABLE IN PORTAL'=$AvailableInPortal; 'BODY'= $_}
    }
} 

$csv_file_array | export-csv $file -NoTypeInformation