# android-dev-tools
### What it is ?
> Android系统、驱动开发者提高工作效率的小工具


### Installation
1. 拷贝或链接到PATH某个目录下
2. 在.bashrc或.zshrc中加入
```bash
alias amm='. amm.sh'
```

### Usage
- #### apush

```bash
apush file1 file2 ...   # 一次push多个文件，根据在out目录的路劲自动选择push位置
apush out/target/product/xxx/system/lib/libui.so # 自动push到system/lib/libui.so
```

![](https://github.com/TUSSON/android-dev-tools/blob/master/res/apush.png)

- #### akill

可同时选择多个进程，一次杀掉
依赖[fzf](https://github.com/junegunn/fzf)

```bash
akill PATTERN           # 搜到PATTERN匹配的进程名，然后adb shell kill
```

![](https://github.com/TUSSON/android-dev-tools/blob/master/res/akill.gif)

- #### amm

1. 根据参数是否有传入模块路劲觉得调用mm/mmm
2. 根据本次更新的文件，自动push到对应位置
3. 查找和这次更新文件依赖的进程，kill掉(需要 -k选项)

```bash
amm [-k] [module_path]
```

![](https://github.com/TUSSON/android-dev-tools/blob/master/res/amm.gif)

### ToDo
增加apull，实现pull可以使用通配符，一次Pull多个匹配文件
