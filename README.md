#  armsoft

> armsoft是基于梅林384的软件中心，其与梅林380软件中心的插件不兼容！armsoft仅适用于koolshare 梅林384平台，且linux内核为2.6.36.4的armv7l架构的路由器！
>

## 机型兼容

使用armsoft软件中心，必须满足机型和固件两个要求：

1. 机型必须是架构为armv7l，linux内核2.6.36.4的，例如以下机型都是这种架构的机型，因为他们都使用了博通bcm4708/9这种CPU。
   1. 华硕`RT-AC56U` `RT-AC68U` `RT-AC66U-B1` `RT-AC1900P` `RT-AC87U` `RT-AC88U` `RT-AC3100` `RT-AC3200` `RT-AC5300`
   2. 网件`R6300V2` `R6400` `R6900` `R7000` `R8000` `R8500` `R8000`
   3. linksys EA系列：`EA6200` `EA6400` `EA6500v2` `EA6700` `EA6900`
   4. 华为：`ws880`
   5. 斐讯`K3`
   
2. 这些机器必须使用koolshare 梅林**384**固件！即使第1项条件满足，但是如果koolshare开发组没有推出该机型的梅林**384**改版固件，那么本软件中心也无法支持，比如斐讯`K3`等。

3. 目前支持**armsoft**的机型：

    * 华硕 RT-AC68U
    - 华硕 RT-AC66U-B1
    - 华硕 RT-AC1900
    - 华硕 RT-AC1900P
    - 华硕 RT-AC87U 
    - 华硕 RT-AC88U
    - 华硕 RT-AC3100
    - 华硕 RT-AC3200
    - 华硕 RT-AC5300
    
    详情请前往koolshare论坛固件下载地址：[https://koolshare.cn/thread-164857-1-1.html](https://koolshare.cn/thread-164857-1-1.html)

## 用户须知

- 本项目，即[梅林arm384软件中心（armsoft）](https://github.com/koolshare/armsoft)与[梅林arm380软件中心](https://github.com/koolshare/koolshare.github.io)的插件不兼容！所以不要用离线安装功能安装其它平台的软件中心！！
- 除非你要安装的插件作者明确表示他的插件可以用于arm384软件中心，或者插件来源于armsoft内本身的插件，才可以安装！！

## 开发须知：

如果你是开发者，想要为armsoft开发新的插件，并用离线包的方式进行传播，请了解armsoft是基于koolshare 1.5代软件中心api开发，其和前代梅林380软件中心不同，并且不兼容（因为web api）！

1. 在web方面：此版软件中心在web上使用的是软件中心1.5代的api，与rogsoft一致，即与RT-AC86U, RT-AX88U, GT-AC5300, GT-AX11000所使用的软件中心api一致
2. 在程序方面：由于固件仍然采用了版本为**2.6.36.4**的linux内核，和armv7的编译器，所以相关程序仍然是armv7架构程序，与梅林380固件所用的二进制程序文件一致
3. 为了避免用户从梅林380升级到梅林384后，使用错误的平台的软件中心，因此，此版本软件中心对离线安装包需要做验证。安装时需要验证安装包内是否含有`.valid`文件，且文件内含有`arm384`字符串。相关链接：[验证代码](https://github.com/koolshare/armsoft/blob/master/softcenter/softcenter/scripts/ks_tar_install.sh#L51-L62)，[验证示例](https://github.com/koolshare/armsoft/blob/master/koolproxy/koolproxy/.valid)
4. 为了避免用户讲本项目内的离线安装包用于其它不兼容的软件中心平台，因此本项目中所有的安装包内的`install.sh`都需要进对安装的固件/平台进行检测，示例：来自本项目koolproxy的[install.sh](https://github.com/koolshare/armsoft/blob/master/koolproxy/koolproxy/install.sh#L9-L27)。

## koolshare几个版本的软件中心区别

|  软件中心   |                        arm380软件中心                        |                        arm384软件中心                        |                     hnd软件中心(本项目)                      | qca软件中心                                                  |                    软路由-酷软                    |
| :---------: | :----------------------------------------------------------: | :----------------------------------------------------------: | :----------------------------------------------------------: | ------------------------------------------------------------ | :-----------------------------------------------: |
|  项目名称   | [koolshare.github.io](https://github.com/koolshare/koolshare.github.io) |       [armsoft](https://github.com/koolshare/armsoft)        |       [rogsoft](https://github.com/koolshare/rogsoft)        | [qcasoft](https://github.com/koolshare/qcasoft)              | [ledesoft](https://github.com/koolshare/ledesoft) |
|  适用架构   |                            armv7l                            |                            armv7l                            |                         armv7l/armv8                         | armv7l                                                       |                        x64                        |
|    平台     |                             arm                              |                             arm                              |                          hnd/axhnd                           | qca-ipq806x                                                  |                     by fw867                      |
|  linux内核  |                           2.6.36.4                           |                           2.6.36.4                           |                            4.1.xx                            | 4.4.60                                                       |                       很新                        |
|     CPU     |                          bcm4708/9                           |                          bcm4708/9                           |                       bcm490x/bcm67xx                        | IPQ8074                                                      |                     intel/AMD                     |
|  固件版本   |                    koolshare 梅林**380**                     |                    koolshare 梅林**384**                     |                     koolshare 梅林/官改                      | koolshare 官改                                               |                   OpenWRT/LEDE                    |
| 软件中心api |                          **1.0** 代                          |                          **1.5** 代                          |                          **1.5** 代                          | **1.5** 代                                                   |                    **1.5** 代                     |
| 代表机型-1  | [RT-AC68U 改版梅林380](https://koolshare.cn/thread-139322-1-1.html) | [RT-AC88U 改版梅林384](https://koolshare.cn/thread-164857-1-1.html) | [RT-AC86U 改版梅林](https://koolshare.cn/thread-127878-1-1.html) | [RT-AX89X 官改固件](https://koolshare.cn/thread-188090-1-1.html) |                         \                         |
| 代表机型-2  | [RT-AC88U 改版梅林380](https://koolshare.cn/thread-139322-1-1.html) | [RT-AC5300 改版梅林384](https://koolshare.cn/thread-164857-1-1.html) | [GT-AC5300 华硕官改](https://koolshare.cn/thread-130902-1-1.html) |                                                              |                         \                         |
| 代表机型-3  | [R7000 改版梅林380](https://koolshare.cn/thread-139324-1-1.html) |                                                              | [RT-AX88U 改版梅林](https://koolshare.cn/thread-158199-1-1.html) |                                                              |                         \                         |



