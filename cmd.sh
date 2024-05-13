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

inject_fake_wechat_version() {
  while true; do
      pid=$(lsof -i :19088 | grep "LISTEN" | awk '{print $2}')
      if [ -n "$pid" ]; then
          echo "WeChat is running, pid: $pid"
          wine 'C:\fake.exe' "$pid" '3.9.5.81' '3.9.10.19'
          echo "inject process done"
          break
      else
          echo "inject process not ready, retry in 1s..."
          sleep 1
      fi
  done
}

inject_fake_wechat_version &

wine 'C:\DllInjector.exe' 'C:\wxhelper.dll' WeChat.exe 2>&1

wait
