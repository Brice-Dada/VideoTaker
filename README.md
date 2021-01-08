# VideoTaker

## 概述

小视频录制用到了**AVFoundation** 框架的 **AVCaptureSession** 类来捕获视频、音频的输入，**AVCaptureVideoPreviewLayer**可以将摄像头拍摄的画面实时呈现到ViewController，**AVCaptureMovieFileOutput**可以录制视频到指定的文件沙盒路径，**AVAssetExportSession**可以将上面录制的视频文件**压缩**之后以**AVFileType**支持的格式保存到本地。

## 功能

点击“红色”按钮，开始录制视频。默认先保存到 NSTemporaryDirectory 目录下，命名为 taked_temp_video.mov。

再次点击“红色”按钮或倒计时结束，停止视频录制，通过**AVPlayerLayer**回放已经录制的视频。

点击完成按钮，将录制好的录像再**压缩**，然后存储为mp4格式的视频后将路径返回给调用控制器。

## 效果图：

![image_pre](https://github.com/briceZhao/VideoTaker/blob/images/image_pre.PNG)



![image_recording](https://github.com/briceZhao/VideoTaker/blob/images/image_recording.PNG)



![image_finish](https://github.com/briceZhao/VideoTaker/blob/images/image_finish.PNG)