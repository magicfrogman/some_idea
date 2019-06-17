@echo off
title   硬件检测
sc config winmgmt start= auto >nul 2<&1
net start winmgmt 2>1nul
setlocal ENABLEDELAYEDEXPANSION
::set /p na=请输入姓名：
echo 姓名：%na%>硬件检测报告.txt
echo 电脑主机名：%COMPUTERNAME%>>硬件检测报告.txt
for /f "tokens=2,* delims=:" %%a in ('systeminfo^|find "OS 名称"') do (
echo 操作系统：%%a>>硬件检测报告.txt
)
::echo 操作系统：%OS%>>硬件检测报告.txt
echo CPU：>>硬件检测报告.txt
for /f "tokens=1,* delims==" %%a in ('wmic cpu get name^,ExtClock^,CpuStatus^,Description /value') do (
  set /a tee+=1
  if "!tee!" == "3" echo     CPU个数   = %%b>>硬件检测报告.txt
  if "!tee!" == "4" echo     处理器版本   = %%b>>硬件检测报告.txt
  if "!tee!" == "5" echo     外   频   = %%b>>硬件检测报告.txt
  if "!tee!" == "6" echo     名称  = %%b>>硬件检测报告.txt
)
set tee=0
echo.
echo 主版：>>硬件检测报告.txt
for /f "tokens=1,* delims==" %%a in ('wmic BASEBOARD get Manufacturer^,Product^,Version^,SerialNumber /value') do (
  set /a tee+=1
  if "!tee!" == "3" echo     制造商   = %%b>>硬件检测报告.txt
  if "!tee!" == "4" echo     型 号   = %%b>>硬件检测报告.txt
  if "!tee!" == "5" echo     序列号   = %%b>>硬件检测报告.txt
  if "!tee!" == "6" echo     版 本   = %%b>>硬件检测报告.txt
)
set tee=0
echo.
echo 硬 盘：>>硬件检测报告.txt
for /f "tokens=1,* delims==" %%a in ('wmic DISKDRIVE get model^,interfacetype^,size^,totalsectors^,partitions /value') do (
  set /a tee+=1
  if "!tee!" == "3" echo     接口类型 = %%b>>硬件检测报告.txt
  if "!tee!" == "4" echo     硬盘型号 = %%b>>硬件检测报告.txt
  if "!tee!" == "5" echo     分区数   = %%b>>硬件检测报告.txt
  if "!tee!" == "6" echo     容   量 = %%b>>硬件检测报告.txt
  if "!tee!" == "7" echo     总扇区   = %%b>>硬件检测报告.txt
)
echo.
echo 内   存：>>硬件检测报告.txt
for /f "tokens=1,* delims==" %%a in ('systeminfo^|find "内存"') do (
  echo       %%a 4534 %%b >>硬件检测报告.txt
)
echo.
echo 显示器：>>硬件检测报告.txt
for /f "tokens=1,* delims==" %%a in ('wmic DESKTOPMONITOR get name^,ScreenWidth^,ScreenHeight^,PNPDeviceID /value') do (
  set /a tee+=1
  if "!tee!" == "3" echo     类   型 = %%b>>硬件检测报告.txt
  if "!tee!" == "4" echo     其他信息 = %%b>>硬件检测报告.txt
  if "!tee!" == "5" echo     屏幕高   = %%b>>硬件检测报告.txt
  if "!tee!" == "6" echo     屏幕宽   = %%b>>硬件检测报告.txt
)
set tee=0
echo.
echo 网 卡：>>硬件检测报告.txt
for /f "tokens=1,* delims==" %%a in ('wmic NICCONFIG where "DNSEnabledForWINSResolution='FALSE'" get ipaddress^,macaddress^,description /value') do (
  set /a tee+=1
  if "!tee!" == "3" echo     网卡类型 = %%b>>硬件检测报告.txt
  if "!tee!" == "4" echo     网卡IP   = %%b>>硬件检测报告.txt
  if "!tee!" == "5" echo     网卡MAC   = %%b>>硬件检测报告.txt
)
set tee=0
pause