#!/bin/bash

# 构建项目
echo "Building project..."
npm run build

# 进入dist目录
cd dist

# 初始化git仓库（如果不存在）
if [ ! -d ".git" ]; then
    echo "Initializing git repository..."
    git init
    git add .
    git commit -m "Deploy to GitHub Pages"
fi

# 添加远程仓库（如果不存在）
if ! git remote | grep -q origin; then
    echo "Adding remote origin..."
    git remote add origin https://github.com/Carinda08/ThinsRecord.git
fi

# 强制推送到gh-pages分支
echo "Pushing to gh-pages branch..."
git add .
git commit -m "Update deployment $(date)"
git push -f origin master:gh-pages

echo "Deployment completed!"
echo "Your site should be available at: https://carinda08.github.io/ThinsRecord/"
