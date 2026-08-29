# Tesseract OCR 使用指南

## 1. Tesseract 是什么

Tesseract 是一个开源 OCR（Optical Character Recognition，光学字符识别）引擎，用来把图片中的印刷文字识别成可编辑、可搜索的文本。

适用场景：

- 提取截图、照片和扫描件中的中文、英文
- 识别合同、票据等版面相对清晰的图片
- 为扫描版 PDF 生成文字内容或可搜索文字层
- 输出纯文本、PDF、TSV、hOCR、ALTO XML 等格式

Tesseract 不是大语言模型，不负责理解内容。复杂表格、特殊排版、模糊照片和手写文字的识别效果通常有限。

本机环境（2026-08-17）：

```text
Tesseract 5.5.2
程序路径：/usr/local/bin/tesseract
语言目录：/usr/local/share/tessdata/
```

本机已经安装完整语言包，包括：

```text
chi_sim       简体中文
chi_tra       繁体中文
chi_sim_vert  竖排简体中文
chi_tra_vert  竖排繁体中文
eng           英文
osd           方向和文字系统检测
```

## 2. 安装

### macOS

```bash
brew install tesseract
brew install tesseract-lang
```

第二条命令用于安装额外语言模型。验证安装：

```bash
tesseract --version
tesseract --list-langs
```

### Ubuntu / Debian

```bash
sudo apt update
sudo apt install tesseract-ocr
sudo apt install tesseract-ocr-chi-sim tesseract-ocr-eng
```

繁体中文语言包：

```bash
sudo apt install tesseract-ocr-chi-tra
```

### Windows

安装 Windows 版 Tesseract，安装时选择 Chinese Simplified、Chinese Traditional、English 等语言包。默认程序通常位于：

```text
C:\Program Files\Tesseract-OCR\tesseract.exe
```

将该目录加入系统 `PATH` 后验证：

```powershell
tesseract --version
tesseract --list-langs
```

## 3. 基本语法

```bash
tesseract 输入图片 输出基础名称 [选项] [输出格式]
```

例如：

```bash
tesseract image.png result -l chi_sim+eng
```

会生成 `result.txt`。第二个参数是输出基础名称，不是完整文件名。

直接输出到终端：

```bash
tesseract image.png stdout -l chi_sim+eng
```

## 4. 常用识别命令

简体中文：

```bash
tesseract image.png stdout -l chi_sim
```

中英文混排：

```bash
tesseract image.png stdout -l chi_sim+eng
```

繁体中文和英文：

```bash
tesseract image.png stdout -l chi_tra+eng
```

输出文本文件：

```bash
tesseract image.png result -l chi_sim+eng
```

识别整块文章或截图：

```bash
tesseract screenshot.png stdout -l chi_sim+eng --psm 6
```

识别单行文字：

```bash
tesseract line.png stdout -l chi_sim+eng --psm 7
```

识别零散文字：

```bash
tesseract image.png stdout -l chi_sim+eng --psm 11
```

识别竖排简体中文：

```bash
tesseract vertical.png stdout -l chi_sim_vert --psm 5
```

## 5. 页面分割模式

`--psm` 告诉 Tesseract 图片中的文字大致如何排列：

| 参数 | 用途 |
|---|---|
| `--psm 3` | 自动分析页面，默认模式 |
| `--psm 5` | 单个纵向排列文字块 |
| `--psm 6` | 单个统一文字块，适合文章截图 |
| `--psm 7` | 单行文字 |
| `--psm 8` | 单个词 |
| `--psm 11` | 稀疏、零散文字 |
| `--psm 12` | 带方向检测的稀疏文字 |
| `--psm 13` | 单行原始文字 |

识别效果不理想时，通常依次尝试 `3`、`6`、`11`：

```bash
tesseract --help-psm
```

## 6. 输出格式

### 可搜索 PDF

```bash
tesseract scan.png result -l chi_sim+eng pdf
```

生成 `result.pdf`，原图片上会附加可搜索、可复制的文字层。

同时输出文本和 PDF：

```bash
tesseract scan.png result -l chi_sim+eng txt pdf
```

### TSV

```bash
tesseract image.png result -l chi_sim+eng tsv
```

`result.tsv` 包含页码、行、词、文字坐标、宽高、置信度和识别内容，适合程序化分析。

### hOCR 和 ALTO XML

```bash
tesseract image.png result -l chi_sim+eng hocr
tesseract image.png result -l chi_sim+eng alto
```

它们用于保留文字位置和版面信息。

## 7. 处理扫描版 PDF

Tesseract 通常不直接读取 PDF。先用 Poppler 将 PDF 页面转换为图片：

```bash
mkdir pages
pdftoppm -png -r 300 input.pdf pages/page
```

再逐页 OCR，并合并为一个文本文件：

```bash
for image in pages/page-*.png; do
  tesseract "$image" stdout -l chi_sim+eng --psm 3
done > result.txt
```

转换指定页码：

```bash
pdftoppm -f 2 -l 5 -png -r 300 input.pdf pages/page
```

OCR 前先检查 PDF 是否已有文字层：

```bash
pdftotext input.pdf -
```

如果能正常输出文字，直接使用 `pdftotext` 更快、更准确。

## 8. 提高准确率

- 文档使用约 300 DPI
- 单字高度最好超过 20 像素
- 保持页面水平，减少倾斜和透视变形
- 增强文字与背景的对比度
- 裁掉无关边框、图标和大面积空白
- 根据版面选择合适的 `--psm`
- 中英文混排使用 `chi_sim+eng`
- 避免反复压缩 JPEG

本机可以用 macOS 自带的 `sips` 放大图片：

```bash
sips --resampleWidth 2400 image.png --out enlarged.png
tesseract enlarged.png stdout -l chi_sim+eng --psm 6
```

只有图片确实模糊、倾斜或背景复杂时，才需要额外的二值化、去噪等预处理。

## 9. 常见问题

检查可用语言：

```bash
tesseract --list-langs
```

指定语言模型目录：

```bash
tesseract image.png stdout \
  --tessdata-dir /usr/local/share/tessdata \
  -l chi_sim+eng
```

Tesseract 默认输出 UTF-8。出现乱码时，应先检查终端或编辑器编码。

表格场景中，Tesseract 可以识别单元格文字，但不擅长恢复表格结构；手写文字也不是它的主要识别对象。

## 10. 本机推荐命令

```bash
# 普通中英文图片
/usr/local/bin/tesseract image.png stdout -l chi_sim+eng --psm 6

# 整页扫描件
/usr/local/bin/tesseract scan.png result -l chi_sim+eng --psm 3

# 零散界面文字
/usr/local/bin/tesseract screenshot.png stdout -l chi_sim+eng --psm 11
```
