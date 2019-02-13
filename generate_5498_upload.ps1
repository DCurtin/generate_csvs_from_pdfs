#parameters
$file= 'C:\Users\dcurtin\Desktop\5498_doc.csv'
$AvailableInPortal='FALSE'
$description='This substitute 5498 is not final and may be subject to change'
$todays_date = Get-Date -UFormat '%m/%d/%Y'
$doc_name = (Get-Date -UFormat '%Y-%m-%d') + ' Tax Document'
$doc_type = 'Tax Document'

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
        $id = $HashTable[$matches[0]]
        $csv_file_array += New-Object PSObject -Property @{'ACCOUNT ID'=$id; 'ACCOUNT NAME'=$matches[0]; 'DESCRIPTION'=$description; 'Content Type'='application/pdf'; 'DOC TYPE'=$doc_type; 'DOC DATE'=$todays_date; 'DOC NAME'=$doc_name;' AVAILABLE IN PORTAL'=$AvailableInPortal; 'BODY'= $_}
    }
} 

$csv_file_array | export-csv $file -NoTypeInformation