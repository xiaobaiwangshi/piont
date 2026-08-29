# 音视频与 FFmpeg

## 基础知识

### 媒体概念

- 分辨率：每帧像素尺寸，如 1280×720、1920×1080、3840×2160。
- 帧率：每秒帧数，如 24/25/30/60 fps。
- 码率：单位时间的数据量，影响体积和传输带宽。
- 编码：压缩音视频，如 H.264/AVC、H.265/HEVC、AV1、AAC、Opus。
- 封装：组合音视频、字幕和元数据，如 MP4、Matroska、MPEG-TS。

H.264 是编码格式，MP4 是封装格式；“MP4 视频一定是 H.264”不成立。原笔记中的“H.564”是笔误，应为 H.264 或 H.265。

### I/P/B 帧与 GOP

- I 帧：可独立解码的帧。
- P 帧：参考过去帧预测。
- B 帧：可参考前后帧，压缩效率高但增加重排和延迟。
- GOP：从一个随机访问点到后续帧的一组编码结构。

PTS 决定展示时间，DTS 决定解码时间；存在 B 帧时解码顺序和展示顺序可能不同。

### MP4 与 TS

- MP4 用 box 组织：`moov` 保存轨道和索引元数据，`mdat` 保存媒体数据。
- 普通 MP4 把 `moov` 放前面有利于渐进播放，可使用 `-movflags +faststart`。
- MPEG-TS 由固定长度传输包组成，没有 MP4 的 `moov/mdat` box。

## 高阶知识

### CRF、preset 与 tune

- CRF：恒定质量目标，x264 常用范围约 18-28，值越低质量越高、文件通常越大。
- preset：编码速度与压缩效率取舍；越慢通常在相同质量下文件更小，不会让解码端按同等比例变慢。
- tune：针对内容/指标调整，如 film、animation、grain、zerolatency；不是必选项。

不存在“画质完全不损失又显著压缩”的有损编码方案。转码时必须在质量、体积和编码成本间选择；真正无损通常体积很大。

### HLS 与关键帧

分片最好从独立可解码关键帧开始。30fps、目标 6 秒分片时，GOP 可从约 180 帧开始验证：

```text
GOP frames = fps × segment seconds
```

场景切换、可变帧率和编码器行为会影响实际结果，需用 ffprobe 检查。

`split_by_time` 允许按时间切分而不保证关键帧边界，与 `independent_segments` 的语义可能冲突。点播优先强制关键帧并让 HLS 在关键帧处分片。

### HLS 加密与 DRM

- AES-128：整个分片加密，播放器获取 key 后解密。
- SAMPLE-AES/CENC：加密媒体样本，常与 DRM 结合。
- DRM：Widevine、FairPlay、PlayReady 等许可证与客户端安全链。

静态 AES key、Token、二次加密不能阻止已授权且被控制的客户端提取明文。安全目标应是缩短授权、绑定身份/设备、控制许可证、动态水印、监控和追责。

## 使用案例

### MP4 压缩

```bash
ffmpeg -i input.mp4 \
  -vf 'scale=1280:-2:flags=lanczos' \
  -c:v libx264 -crf 23 -preset slow -pix_fmt yuv420p \
  -c:a aac -b:a 128k \
  -movflags +faststart output.mp4
```

如果源视频宽度小于 1280，不应无意义放大；可使用条件表达式或先探测尺寸。音频不能总用 `-c:a copy`：源编码与目标封装/HLS 播放端可能不兼容。

### HLS 点播

以 30fps、6 秒为例：

```bash
ffmpeg -i input.mp4 \
  -c:v libx264 -crf 23 -preset slow -pix_fmt yuv420p \
  -g 180 -keyint_min 180 -sc_threshold 0 \
  -force_key_frames 'expr:gte(t,n_forced*6)' \
  -c:a aac -b:a 128k \
  -f hls -hls_time 6 -hls_playlist_type vod -hls_list_size 0 \
  -hls_flags independent_segments \
  -hls_segment_filename 'output/segment_%05d.ts' \
  output/playlist.m3u8
```

先创建输出目录。若源为可变帧率或转为不同帧率，使用按时间强制关键帧比固定帧号更直观。

### AES-128 HLS

key info 文件三行通常为：播放端访问的 key URI、本地 key 文件路径、可选 IV（32 个十六进制字符，不带 `0x`，按 FFmpeg 当前版本验证）。key 文件必须是 16 字节二进制随机数据。

密钥 URI 必须走 HTTPS、短期鉴权和访问控制；不能把 key 永久公开放在对象存储。

### MP3 压缩与滤镜

```bash
ffmpeg -i input.mp3 -af 'highpass=f=100,volume=1.5' \
  -c:a libmp3lame -b:a 64k -ac 1 -ar 22050 output.mp3
```

`highpass` 是音频滤镜，不是独立输出选项，因此原命令中的 `-highpass 100` 会报 `Unrecognized option`。

### 多码率 HLS

为 360p/720p 等梯度分别编码，保证相同分片时长和对齐关键帧，生成 variant playlist 与 master playlist。不同梯度的码率应按内容复杂度、目标屏幕和带宽实测，不套固定表。

## 常见问题与排查

- `No option name near scale`：检查 shell 引号是否被转义成字面量，命令行一般写 `-vf 'scale=720:-2'`。
- HLS 拖动/预加载差：检查关键帧与分片对齐、VOD playlist、CDN range/cache 和播放器策略。
- ffprobe 读取加密 TS 失败：先通过 m3u8 与正确 key/IV 解密，单独 TS 不一定包含足够上下文。
- 音画不同步：检查 time base、PTS/DTS、输入起点、VFR 和 `-shortest` 的使用。
- 转码打满服务器：限制任务并发，按编码器线程、CPU、内存和 I/O 压测，不能按“4 核固定可跑几个”给永久答案。

## 延伸阅读

- [音视频系统核心机制](../07-核心机制深入/08-音视频系统机制.md)
- [实验与验收清单](../07-核心机制深入/09-实验与验收清单.md)
