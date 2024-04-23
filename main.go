package main

import (
	"context"
	"github.com/eatmoreapple/env"
	"github.com/eatmoreapple/wxhelper/apiserver"
	"github.com/rs/zerolog/log"
	"gopkg.in/natefinch/lumberjack.v2"
	"io"
	stdlog "log"
	"os"
)

func NewRotateWriter() io.Writer {
	return &lumberjack.Logger{
		Filename:   "logger.log",
		MaxSize:    10, // 单位：MB
		MaxBackups: 5,
		MaxAge:     7, // 单位：天
		Compress:   true,
	}
}

func main() {
	writer := io.MultiWriter(NewRotateWriter(), os.Stdout)
	srv := apiserver.Default()
	srv.OnContext = func(ctx context.Context) context.Context {
		log.Logger = log.Output(writer).With().Caller().Timestamp().Logger()
		return log.Logger.WithContext(ctx)
	}
	stdlog.Fatal(srv.Run(env.Name("RUN_PORT").StringOrElse(":19089")))
}
