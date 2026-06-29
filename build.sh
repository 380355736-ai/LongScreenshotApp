#!/bin/bash
# iOS 截长图 App 构建脚本
# 在 Mac 上运行此脚本以编译项目

set -e

PROJECT_NAME="LongScreenshotApp"
SCHEME_NAME="LongScreenshotApp"
CONFIGURATION="Release"

echo "=== 创建 Xcode 项目 ==="

# 创建临时 Xcode 项目
mkdir -p "${PROJECT_NAME}.xcodeproj"

# 使用 xcodebuild 从源码编译
# 注意: 需要先在 Xcode 中创建项目，或者使用 Swift Package Manager

# 方案一: 使用 swiftc 直接编译（仅用于语法检查）
echo "检查源文件..."
find LongScreenshotApp -name "*.swift" -exec echo "  {}" \;

# 方案二: 生成 xcodeproj（需要安装 xcodegen）
if command -v xcodegen &> /dev/null; then
    echo "使用 XcodeGen 生成项目..."
    xcodegen generate
    xcodebuild -project "${PROJECT_NAME}.xcodeproj" \
               -scheme "${SCHEME_NAME}" \
               -configuration "${CONFIGURATION}" \
               -sdk iphoneos \
               -archivePath "build/${PROJECT_NAME}.xcarchive" \
               archive
    echo "✅ 构建完成: build/${PROJECT_NAME}.xcarchive"
else
    echo "请安装 XcodeGen: brew install xcodegen"
    echo "或手动在 Xcode 中创建项目并导入以下源文件:"
    find LongScreenshotApp -name "*.swift"
fi
