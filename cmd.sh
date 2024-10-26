#!/usr/bin/env bash

sudo mv /home/app/.wine/drive_c/apiserver.conf /etc/supervisord.d/apiserver.conf

exec sudo -E bash -c 'supervisord -c /etc/supervisord.conf -l /var/log/supervisord.log' &

sleep 10

if [ -d "/home/app/.wine/drive_c/Program Files/Tencent" ]; then
  echo '启动64位微信'
  wine 'C:\Program Files\Tencent\WeChat\WeChat.exe' &
else
  echo '启动32位微信'
  wine 'C:\Program Files (x86)\Tencent\WeChat\WeChat.exe' &
fi

sleep 10

wine 'C:\DllInjector.exe' 'C:\wxhelper.dll' WeChat.exe 2>&1

wine 'version.exe' 2>&1

wait
