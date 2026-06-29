# 截长图 - iOS 长截图 App

## 功能

- 📱 **屏幕录制拼接**：录制屏幕 + 滚动 → 自动拼接成长图
- 🔍 **智能重叠检测**：使用 Vision 框架自动识别相邻帧重叠区域
- ✂️ **自动裁剪优化**：去除黑边，输出干净长图
- 💾 **保存到相册**：一键保存拼接结果

## 项目结构

```
LongScreenshotApp/
├── App.swift                    # 应用入口
├── ContentView.swift            # 主容器
├── Recorder/
│   └── ScreenRecorder.swift     # ReplayKit 录制
├── Stitcher/
│   ├── FrameExtractor.swift     # 视频帧提取
│   ├── OverlapDetector.swift    # Vision 重叠检测
│   └── ImageStitcher.swift      # CoreGraphics 拼接
├── Views/
│   ├── HomeView.swift           # 首页
│   ├── ProcessingView.swift     # 处理进度
│   └── ResultView.swift         # 结果预览
├── Utils/
│   └── ImageSaver.swift         # 保存到相册
├── Info.plist                   # 应用配置
└── project.yml                  # XcodeGen 配置
```

## 编译方式

### 方式一：GitHub Actions（推荐）
1. 将代码推送到 GitHub 仓库
2. Actions 自动编译，生成 .ipa 文件
3. 下载 .ipa 用 AltStore/Sideloadly 安装到 iPhone

### 方式二：Mac 本地编译
```bash
brew install xcodegen
xcodegen generate
open LongScreenshotApp.xcodeproj
# 在 Xcode 中选择 Signing Team 并 Build
```

### 方式三：云端 Mac
- MacinCloud / MacStadium 等远程 Mac 服务

## 使用流程

1. 打开 App → 点击「开始录制」
2. 系统弹出屏幕录制权限 → 允许
3. 切换到任意 App（Safari/微信等）→ 慢慢滚动浏览
4. 返回截长图 App → 点击「停止录制」
5. 自动拼接 → 预览长图 → 保存到相册

## 技术栈

| 组件 | 技术 |
|------|------|
| UI | SwiftUI |
| 录屏 | ReplayKit (RPScreenRecorder) |
| 视频处理 | AVFoundation |
| 图像配准 | Vision (VNTranslationalImageRegistration) |
| 图像合成 | CoreGraphics |
| 最低版本 | iOS 15.0 |
