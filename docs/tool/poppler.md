# Poppler PDF 工具使用指南

## 1. Poppler 是什么

Poppler 是一套开源 PDF 解析、渲染和转换工具，核心使用 C++ 编写，源自 Xpdf 项目。

主要用途：

- 查看 PDF 页数、尺寸、作者和加密状态
- 提取 PDF 中已有的文字
- 将 PDF 页面渲染成 PNG、JPEG 等图片
- 提取 PDF 内嵌的原始图片
- 拆分、合并 PDF
- 检查字体、附件和数字签名
- 转换为 HTML、PostScript、SVG 等格式

Poppler 本身不做 OCR。扫描版 PDF 的典型处理链路是：

```text
Poppler：PDF -> 图片
Tesseract：图片 -> 文字
```

本机环境（2026-08-17）：

```text
Poppler 26.04.0
安装目录：/usr/local/Cellar/poppler/26.04.0/
命令目录：/usr/local/bin/
```

## 2. 常用工具

| 命令 | 用途 |
|---|---|
| `pdfinfo` | 查看页数、尺寸、作者、加密状态等 |
| `pdftotext` | 提取 PDF 中已有的文字 |
| `pdftoppm` | 将页面渲染为 PNG、JPEG、PPM |
| `pdftocairo` | 使用 Cairo 渲染 PNG、JPEG、SVG、PS |
| `pdfimages` | 提取 PDF 中嵌入的原始图片 |
| `pdfseparate` | 把 PDF 拆成单页文件 |
| `pdfunite` | 合并多个 PDF |
| `pdffonts` | 查看 PDF 使用的字体 |
| `pdftohtml` | 将 PDF 转成 HTML 或 XML |
| `pdftops` | 将 PDF 转成 PostScript |
| `pdfattach` | 向 PDF 添加附件 |
| `pdfdetach` | 查看或提取 PDF 附件 |
| `pdfsig` | 检查 PDF 数字签名 |

## 3. 安装

### macOS

```bash
brew install poppler
```

验证和更新：

```bash
pdfinfo -v
brew upgrade poppler
brew list poppler
```

Apple Silicon Mac 通常安装在 `/opt/homebrew/bin/`，Intel Mac 通常安装在 `/usr/local/bin/`。

### Ubuntu / Debian

```bash
sudo apt update
sudo apt install poppler-utils
```

### Fedora / RHEL

```bash
sudo dnf install poppler-utils
```

### Arch Linux

```bash
sudo pacman -S poppler
```

### Windows

使用 Conda：

```powershell
conda install -c conda-forge poppler
```

使用 MSYS2：

```powershell
pacman -S mingw-w64-ucrt-x86_64-poppler
```

使用 WSL 时，可以直接安装 Ubuntu 的 `poppler-utils`。

## 4. 查看 PDF 信息：pdfinfo

```bash
pdfinfo document.pdf
```

输出通常包括标题、作者、创建时间、页数、页面尺寸、文件大小、加密状态和 PDF 版本。

只查看指定页范围：

```bash
pdfinfo -f 2 -l 5 document.pdf
```

查看页面边界：

```bash
pdfinfo -box document.pdf
```

只查看页数：

```bash
pdfinfo document.pdf | rg '^Pages:'
```

## 5. 提取文字：pdftotext

输出到文本文件：

```bash
pdftotext document.pdf document.txt
```

输出到终端：

```bash
pdftotext document.pdf -
```

尽量保留原始排版：

```bash
pdftotext -layout document.pdf document.txt
```

只提取第 2 到第 5 页：

```bash
pdftotext -f 2 -l 5 document.pdf document.txt
```

指定裁剪区域，单位为 PDF point，72 point 等于 1 英寸：

```bash
pdftotext \
  -x 100 \
  -y 100 \
  -W 400 \
  -H 600 \
  document.pdf \
  result.txt
```

如果 `pdftotext document.pdf -` 能输出正常文字，就不需要 OCR。如果几乎没有输出，PDF 可能是扫描件。

## 6. PDF 页面转图片：pdftoppm

转成 PNG：

```bash
pdftoppm -png document.pdf page
```

生成 `page-1.png`、`page-2.png` 等文件。

屏幕预览通常使用 150 DPI：

```bash
pdftoppm -png -r 150 document.pdf page
```

OCR 通常使用 300 DPI：

```bash
pdftoppm -png -r 300 document.pdf page
```

只转换第 2 到第 5 页：

```bash
pdftoppm -f 2 -l 5 -png -r 300 document.pdf page
```

转成 JPEG：

```bash
pdftoppm -jpeg -jpegopt quality=90 -r 150 document.pdf page
```

只生成单页文件：

```bash
pdftoppm -f 1 -l 1 -singlefile -png document.pdf cover
```

生成 `cover.png`。

按宽度等比例缩放：

```bash
pdftoppm -png -scale-to-x 1600 -scale-to-y -1 document.pdf page
```

## 7. pdftoppm 与 pdftocairo

`pdftoppm` 适合普通图片生成和 OCR：

```bash
pdftoppm -png -r 300 document.pdf page
```

`pdftocairo` 使用 Cairo 图形库，适合对抗锯齿要求较高或需要 SVG 的场景：

```bash
pdftocairo -png -r 300 document.pdf page
pdftocairo -svg -f 1 -l 1 document.pdf page.svg
```

普通 OCR 优先使用 `pdftoppm`，遇到渲染问题时再尝试 `pdftocairo`。

## 8. 提取内嵌图片：pdfimages

查看图片列表：

```bash
pdfimages -list document.pdf
```

尽量按原始格式提取所有图片：

```bash
pdfimages -all document.pdf image
```

JPEG 保持 JPEG：

```bash
pdfimages -j document.pdf image
```

统一输出 PNG：

```bash
pdfimages -png document.pdf image
```

两类命令的区别：

```text
pdftoppm：把完整页面渲染成图片
pdfimages：取出 PDF 中原本嵌入的图片
```

## 9. 拆分与合并 PDF

拆成单页 PDF：

```bash
pdfseparate document.pdf page-%d.pdf
```

只拆第 3 到第 5 页：

```bash
pdfseparate -f 3 -l 5 document.pdf page-%d.pdf
```

合并文件：

```bash
pdfunite first.pdf second.pdf third.pdf merged.pdf
```

输入顺序就是合并后的页面顺序。

## 10. 字体、HTML、附件和签名

查看字体及其嵌入、Unicode 映射状态：

```bash
pdffonts document.pdf
```

如果字体没有 Unicode 映射，`pdftotext` 可能无法正确提取文字。

转换为单一 HTML：

```bash
pdftohtml -s -noframes document.pdf output.html
```

转换为 XML：

```bash
pdftohtml -xml document.pdf output.xml
```

查看附件列表：

```bash
pdfdetach -list document.pdf
```

提取所有附件：

```bash
mkdir attachments
pdfdetach -saveall -o attachments document.pdf
```

添加附件并生成新 PDF：

```bash
pdfattach document.pdf attachment.xlsx output.pdf
```

检查数字签名：

```bash
pdfsig signed-document.pdf
```

## 11. 加密 PDF

使用用户密码：

```bash
pdfinfo -upw '用户密码' protected.pdf
pdftotext -upw '用户密码' protected.pdf output.txt
```

使用所有者密码：

```bash
pdftotext -opw '所有者密码' protected.pdf output.txt
```

直接在命令中填写密码可能被 Shell 历史或进程列表记录。Poppler 不用于破解未知密码。

## 12. 扫描 PDF OCR 流程

先尝试直接提取文字：

```bash
pdftotext -layout input.pdf output.txt
```

没有文字时，将页面转换为图片：

```bash
mkdir pages
pdftoppm -png -r 300 input.pdf pages/page
```

然后使用 Tesseract OCR：

```bash
for image in pages/page-*.png; do
  tesseract "$image" stdout -l chi_sim+eng --psm 3
done > output.txt
```

## 13. 快速检查未知 PDF

```bash
pdfinfo document.pdf
pdffonts document.pdf
pdfimages -list document.pdf
pdftotext -f 1 -l 1 -layout document.pdf -
```

这几条命令可以判断 PDF 的页数、加密状态、字体、图片以及是否存在可提取的文字层。

生成首页预览：

```bash
pdftoppm \
  -f 1 \
  -l 1 \
  -singlefile \
  -png \
  -r 150 \
  document.pdf \
  preview
```

## 14. 帮助与限制

查看命令帮助：

```bash
pdfinfo -h
pdftotext -h
pdftoppm -h
pdfimages -h
```

也可以使用系统手册：

```bash
man pdftotext
man pdftoppm
man pdfimages
```

Poppler 不负责 OCR、修改页面已有文字、复杂表格结构恢复、表单编辑或破解未知密码。页面旋转、删页、水印等编辑任务通常使用 `qpdf`、`pikepdf` 或专门的 PDF 编辑工具。
