FROM golang:1.22 as builder

WORKDIR /app

COPY . .

ENV GOPROXY=https://goproxy.cn,direct

RUN go mod tidy

RUN CGO_ENABLED=0 GOOS=linux go build --ldflags="-s -w" -o apiserverd main.go

FROM furacas/wine-vnc-box:latest

# 清理环境
RUN sudo rm -rf /tmp/.X0-lock

# 根据传入参数安装微信和wxhelper.dll
ARG WECHAT_URL=https://github.com/tom-snow/wechat-windows-versions/releases/download/v3.9.5.81/WeChatSetup-3.9.5.81.exe
ARG WXHELPER_URL=https://github.com/ttttupup/wxhelper/releases/download/3.9.5.81-v11/wxhelper.dll

WORKDIR /home/app/.wine/drive_c

# 加载注入器
ADD https://github.com/furacas/DllInjector/releases/download/v1.4.0/DllInjector64.exe DllInjector.exe
RUN sudo chown app:app DllInjector.exe && sudo chmod a+x DllInjector.exe

# 安装中文支持及其他必要的Windows组件
RUN apt-get update && apt-get install -y winetricks && winetricks cjkfonts corefonts vcrun2013

# 下载微信
ADD ${WECHAT_URL} WeChatSetup.exe
RUN sudo chown app:app WeChatSetup.exe  && sudo chmod a+x WeChatSetup.exe

# 下载wxhelper.dll
ADD ${WXHELPER_URL} wxhelper.dll

RUN sudo chown app:app wxhelper.dll

RUN ls -lah

# 安装微信
COPY install-wechat.sh install-wechat.sh

COPY 微信降版本.exe /微信降版本.exe

RUN sudo chmod a+x install-wechat.sh && ./install-wechat.sh

RUN rm -rf WeChatSetup.exe && rm -rf install-wechat.sh

EXPOSE 5900 19088

COPY cmd.sh /cmd.sh

RUN sudo chmod +x /cmd.sh

COPY --from=builder /app/apiserver.conf /home/app/.wine/drive_c/apiserver.conf

COPY --from=builder /app/apiserverd /home/app/.wine/drive_c/apiserverd

CMD ["/cmd.sh"]