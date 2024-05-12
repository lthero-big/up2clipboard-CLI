# 下载项目

```
git clone https://gitclone.com/github.com/lthero-big/up2clipboard-CLI.git 
```

进入项目目录
```sh
cd ./up2clipboard-CLI
```

# 配置修改
vim或nano打开`config.txt`，将里面的域名替换成自己的，如https://clip.yourDomain.com


# 运行安装文件
给`install.sh`执行权限，并运行
```sh
sudo chmod +x install.sh
sudo ./install.sh
```

脚本会自己安装需要的环境，运行完成后，即可使用下面的命令进行调用

# 上传文件

```sh
upf somefile.txt --room RoomName
upf --room 'RoomName' somefile.t
upf --room RoomName file*
```

* `file*`: 支持通符号
* **不支持**整个文件夹上传

# 上传文字

支持多种写法

```sh
upt 'Here is some text' --room RoomName
upt --room 'RoomName' 'Here is some text'
echo 'Sample text' | upt --room RoomName
cat notes.txt | upt
```

