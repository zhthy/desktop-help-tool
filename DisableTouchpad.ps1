# ���ҷ��� HID ��׼�Ĵ������豸
$deviceIDPattern = "HID\\ELAN" # HID �豸ID�ı�ʶģʽ��ʹ��˫��б�ܽ���ת�壩

# ��ȡ���з����������豸
$devices = Get-PnpDevice | Where-Object {
    $_.InstanceId -match $deviceIDPattern
}

# ����Ƿ��ҵ��豸
if ($devices.Count -eq 0) {
    Write-Output "δ�ҵ����� HID ��׼�Ĵ������豸��"
    exit
}

# ����������ÿ�������������豸
foreach ($device in $devices) {
    try {
        # ��ȡ�豸ʵ��·��
        $deviceInstanceID = $device.InstanceId
        
        # �����豸
        Disable-PnpDevice -InstanceId $deviceInstanceID -Confirm:$false
        Write-Output "�������豸 '$deviceInstanceID' �ѽ��á�"
    } catch {
        Write-Output "���ô������豸 '$deviceInstanceID' ʧ��: $_"
    }
}
