# 技术规格说明书 — iOS 截长图 App

## 技术选型

| 层面 | 选择 | 理由 |
|------|------|------|
| 语言 | Swift 5.9+ | iOS 原生语言 |
| UI 框架 | SwiftUI | 现代化、声明式、响应式 |
| 录屏 | ReplayKit (RPScreenRecorder) | 唯一合法的 iOS 录屏 API |
| 视频处理 | AVFoundation (AVAssetReader) | 高效逐帧读取 |
| 重叠检测 | Vision (VNTranslationalImageRegistration) | 系统级图像配准 |
| 图像合成 | CoreGraphics (UIGraphicsImageRenderer) | GPU 加速绘制 |
| 项目生成 | XcodeGen (project.yml) | 跨平台项目配置 |
| CI/CD | GitHub Actions (macOS runner) | 免费自动化编译 |

## 架构设计

```
用户操作
    │
    ▼
HomeView ──start──► RPScreenRecorder ──stop──► 视频文件 (.mp4)
                                                     │
                                                     ▼
                                              FrameExtractor
                                              (AVAssetReader)
                                                     │
                                                     ▼
                                              [UIImage] 帧序列
                                                     │
                                                     ▼
                                              OverlapDetector
                                              (Vision 图像配准)
                                                     │
                                                     ▼
                                              [CGFloat] 重叠量
                                                     │
                                                     ▼
                                              ImageStitcher
                                              (CoreGraphics 绘制)
                                                     │
                                                     ▼
                                              长图 UIImage
                                                     │
                                                     ▼
                                              ResultView ──► 保存/分享
```

## 数据流

```
RPScreenRecorder → .mp4 → AVAssetReader → [CGImage] → Vision 配准
→ 重叠偏移量 → CoreGraphics 逐帧绘制 → UIImage 长图 → Photos.app
```

## 配置

- project.yml 使用 XcodeGen 格式
- Info.plist 包含 ReplayKit + PhotoLibrary 权限描述
- 最低部署目标 iOS 15.0
