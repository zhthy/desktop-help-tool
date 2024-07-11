# 查找符合 HID 标准的触摸板设备
$deviceIDPattern = "HID\\ELAN" # HID 设备ID的标识模式（使用双反斜杠进行转义）

# 获取所有符合条件的设备
$devices = Get-PnpDevice | Where-Object {
    $_.InstanceId -match $deviceIDPattern
}

# 检查是否找到设备
if ($devices.Count -eq 0) {
    Write-Output "未找到符合 HID 标准的触摸板设备。"
    exit
}

# 遍历并禁用每个符合条件的设备
foreach ($device in $devices) {
    try {
        # 获取设备实例路径
        $deviceInstanceID = $device.InstanceId
        
        # 禁用设备
        Disable-PnpDevice -InstanceId $deviceInstanceID -Confirm:$false
        Write-Output "触摸板设备 '$deviceInstanceID' 已禁用。"
    } catch {
        Write-Output "禁用触摸板设备 '$deviceInstanceID' 失败: $_"
    }
}
