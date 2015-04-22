$storageAccountName="neudesicarmfiles"
$storageContainerName="staticfilestorage"
$storageKey="OkfPJcPw/XP88PlZ6GkbQAxi5WbHCpK5j6Knq6WoYteprrWZLSWmXh3GdWG/m8cee7/48F9UQH42pDQG1HRV0w=="

$context = New-AzureStorageContext -StorageAccountName $storageAccountName -StorageAccountKey $storageKey
$container = Get-AzureStorageContainer -Name $storageContainerName -Context $context
if (!$container) {
	$container = New-AzureStorageContainer -Name $storageContainerName -Context $context -Permission Blob	
}

Set-AzureStorageBlobContent -Blob "hortonworks\shared-resources.json" -Container $container.Name -File ".\shared-resources.json" -Context $context -Force
Set-AzureStorageBlobContent -Blob "hortonworks\master-node.json" -Container $container.Name -File ".\master-node.json" -Context $context -Force
Set-AzureStorageBlobContent -Blob "hortonworks\name-node.json" -Container $container.Name -File ".\name-node.json" -Context $context -Force
Set-AzureStorageBlobContent -Blob "hortonworks\data-node.json" -Container $container.Name -File ".\data-node.json" -Context $context -Force
Set-AzureStorageBlobContent -Blob "hortonworks\scripts\initialize-master.sh" -Container $container.Name -File ".\scripts\initialize-master.sh" -Context $context -Force

Set-AzureStorageBlobContent -Blob "hortonworks\scripts\prepareDisks.sh" -Container $container.Name -File ".\scripts\prepareDisks.sh" -Context $context -Force
Set-AzureStorageBlobContent -Blob "hortonworks\scripts\initialize-node.sh" -Container $container.Name -File ".\scripts\initialize-node.sh" -Context $context -Force
Set-AzureStorageBlobContent -Blob "hortonworks\scripts\vm-bootstrap.py" -Container $container.Name -File ".\scripts\vm-bootstrap.py" -Context $context -Force
