$storageAccountName="neudesicarmfiles"
$storageContainerName="staticfilestorage"
$storageKey="OkfPJcPw/XP88PlZ6GkbQAxi5WbHCpK5j6Knq6WoYteprrWZLSWmXh3GdWG/m8cee7/48F9UQH42pDQG1HRV0w=="

$context = New-AzureStorageContext -StorageAccountName $storageAccountName -StorageAccountKey $storageKey
$container = Get-AzureStorageContainer -Name $storageContainerName -Context $context
if (!$container) {
	$container = New-AzureStorageContainer -Name $storageContainerName -Context $context -Permission Blob	
}

Set-AzureStorageBlobContent -Blob "cloudera\shared-resources.json" -Container $container.Name -File ".\shared-resources.json" -Context $context -Force
Set-AzureStorageBlobContent -Blob "cloudera\master-node.json" -Container $container.Name -File ".\master-node.json" -Context $context -Force
Set-AzureStorageBlobContent -Blob "cloudera\name-node.json" -Container $container.Name -File ".\name-node.json" -Context $context -Force
Set-AzureStorageBlobContent -Blob "cloudera\data-node.json" -Container $container.Name -File ".\data-node.json" -Context $context -Force
Set-AzureStorageBlobContent -Blob "cloudera\initialize_master.sh" -Container $container.Name -File ".\initialize_master.sh" -Context $context -Force

Set-AzureStorageBlobContent -Blob "cloudera\scripts\bootstrap-cloudera.sh" -Container $container.Name -File ".\scripts\bootstrap-cloudera.sh" -Context $context -Force
Set-AzureStorageBlobContent -Blob "cloudera\scripts\cmxDeployOnIbiza.py" -Container $container.Name -File ".\scripts\cmxDeployOnIbiza.py" -Context $context -Force
Set-AzureStorageBlobContent -Blob "cloudera\scripts\diskFormatAndMount.sh" -Container $container.Name -File ".\scripts\diskFormatAndMount.sh" -Context $context -Force
Set-AzureStorageBlobContent -Blob "cloudera\scripts\hereFileToRunInParallel.sh" -Container $container.Name -File ".\scripts\hereFileToRunInParallel.sh" -Context $context -Force
Set-AzureStorageBlobContent -Blob "cloudera\scripts\initialize-cloudera-server.sh" -Container $container.Name -File ".\scripts\initialize-cloudera-server.sh" -Context $context -Force
Set-AzureStorageBlobContent -Blob "cloudera\scripts\prepareDisks.sh" -Container $container.Name -File ".\scripts\prepareDisks.sh" -Context $context -Force

Set-AzureStorageBlobContent -Blob "cloudera\scripts\initialize-node.sh" -Container $container.Name -File ".\scripts\initialize-node.sh" -Context $context -Force
Set-AzureStorageBlobContent -Blob "cloudera\scripts\updateHosts.sh" -Container $container.Name -File ".\scripts\updateHosts.sh" -Context $context -Force