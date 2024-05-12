# up2clipboard-CLI
upload files and text contents to online clipboard by using CLI

# 配置修改
打开config.txt，将里面的域名替换成自己的，如https://clip.yourDomain.com

# 运行安装文件
进入项目目录
```sh
cd ./up2clipboard-CLI
```

给install.sh执行权限，并运行
```sh
sudo chmod +x install.sh
sudo ./install.sh
```


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

