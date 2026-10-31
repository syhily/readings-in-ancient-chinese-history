# 中国古代史读本（Readings in History: Ancient Chinese History）

陈苏镇　张帆 编 · 北京大学出版社 · 2006 年（上下册）

本项目将《中国古代史读本》（上下册，「大学历史学论文读本系列」之一）PDF 经 [MinerU](https://github.com/opendatalab/MinerU) 双模式（pipeline / vlm）交叉识别、人工校对后排版为 Markdown，再由 pandoc 构建 EPUB 3 电子书。全书选收自近代新史学产生以来公开发表的中国古代史研究论文四十篇：上册自殷周至南北朝（王国维、郭沫若、傅斯年、陈寅恪、唐长孺、周一良等），下册自隋唐至清代（汪篯、严耕望、邓广铭、吴晗、余英时等）。每篇选文前附选文导读与作者介绍，篇末附注释与参考论著。

## 文件结构

| 文件 | 说明 |
| --- | --- |
| `manuscript/00-frontmatter.md` | 前置部分（电子版说明与免责声明） |
| `manuscript/*.md` | 总序、上下册及各篇正文（**所有修改都在对应文件里进行**），构建时按文件名序合并 |
| `metadata.yaml` | pandoc 元数据（书名、作者、语言） |
| `assets/epub.css` | EPUB 样式（正文用阅读器默认字体；标题黑体 / 导读与引文楷体 / 扉页仿宋，字体栈取自 [fonts.css](https://github.com/zenozeng/fonts.css) 跨平台方案） |
| `assets/cover.jpg` | 封面图 |
| `scripts/ocr.sh` | MinerU 双模式分片识别（200 页/片，断点续跑） |
| `scripts/glyph.sh` | 古文字形制作（600dpi 裁切 → potrace SVG 或 PNG 位图，坐标定位见 `docs/workflow.md`） |
| `scripts/build.sh` | pandoc 构建脚本（`--split-level=2` 按篇拆分文件即硬分页；CSS 剥注释后打包，兼容 Clearview） |
| `scripts/ascii-heading-ids.lua` | pandoc Lua 过滤器：标题锚点改写为 ASCII 序号（sec-N），否则中文锚点在 Clearview 等阅读器中目录无法跳转 |
| `Makefile` | `make build` 构建，`make ocr` 识别，`make clean` 清理 |
| `docs/workflow.md` | OCR 交叉校对流程与 Markdown 书写约定的完整说明（含本书版式特化） |
| `中国古代史读本.epub` | 构建产物（不入库，见 Releases） |

原始 PDF 与 OCR 中间结果（`source/`、`ocr/`）不入库，请自行准备。

## 下载

每次打 tag 都会由 GitHub Actions 自动构建 EPUB 并发布到 Releases：

- [下载最新版 EPUB](https://github.com/syhily/readings-in-ancient-chinese-history/releases/latest/download/readings-in-ancient-chinese-history.epub)（直链，始终指向最新 Release）
- [查看全部版本](https://github.com/syhily/readings-in-ancient-chinese-history/releases)

## 构建

```sh
make build    # 生成 build/中国古代史读本.epub
make clean    # 删除构建产物
```

只依赖 [pandoc](https://pandoc.org)。OCR 环节另需 `mineru-open-api`（`npm install -g mineru-open-api`）及 token，详见 `docs/workflow.md`。

## 参与校对与修改

欢迎通过 Issue 或 Pull Request 指正 OCR 讹误与排版问题。修改 `manuscript/` 对应文件后运行 `make build` 重建即可。Markdown 中的排版约定（详见 `docs/workflow.md`）：

- `# 总序` / `# 上册` / `# 下册`：一级标题；`## 篇名[作者]{.zuozhe}`：各篇选文标题（作者楷体小一号）；`#### …`：篇内小节标题（靠左黑体，不进目录）
- `::: {.daodu}`：篇首选文导读与作者介绍（楷体块，导读页版式，后接 `\newpage` 与正文分页）
- `> 文字`：段落式引文（楷体缩进）；`> | 文字`：需逐行换行但换行不是分段的引文；`| 诗行`：诗体引文（行块，每句一行）
- `[（选自……）]{.chuchu}`：篇末出处行（居中小字）；`#### 参考论著 {.cankao}`：篇末参考论著标题（居中黑体）+ 有序列表书目
- `文字^[注释内容]`：行内脚注（EPUB 3 弹注；原书篇末编号注〔N〕一律转为行内脚注，不用 `[^n]` 编号式）
- `**文字**`：黑体强调；`*文字*`：楷体（中文不倾斜）
- `::: {.fangsong}`：扉页信息、出版说明（仿宋）
- `![释读](assets/glyphs/xxx.svg){.glyph}`：行内古文字形（甲骨文/金文 SVG，由 `scripts/glyph.sh` 制作）；字形阵列整组裁为一张图、独占段落、不加 `.glyph`
- 拿不准的字，加 HTML 注释 `<!-- 疑：原书作「x」 -->` 留待复核

## 致谢

- `assets/epub.css` 的跨平台中文字体栈来自 [fonts.css](https://github.com/zenozeng/fonts.css)，Copyright (C) 2013-2018 Zeno Zeng and contributors，[MIT License](https://github.com/zenozeng/fonts.css/blob/main/LICENSE)。
- `assets/epub.css` 的部分排版规则（CJK 换行禁则、悬挂标点、上下标归一、引号等）借鉴 [typo.css](https://github.com/sofish/typo.css)，Copyright (C) 2012 Sofish Lin，[MIT License](https://github.com/sofish/typo.css/blob/master/license.txt)。

## 免责声明

本书著作权归原作者及北京大学出版社所有。本项目仅供个人学习与研究使用，不进行任何商业用途，不用于任何形式的再出版。OCR 识别与人工校对可能存在讹误，内容请以北京大学出版社纸质原书为准。若本仓库内容涉及侵权，请联系仓库所有者，核实后将立即删除。
