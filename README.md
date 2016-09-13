# YQGameCenterTool
####微博：畸形滴小男孩

###iOS端对GameCenter的封装

####使用方法：
#####1把文件拖到XCodeg工程中，并开启工程的GameCenter：
 ![image](https://github.com/976431yang/YQGameCenterTool/blob/master/DEMO/screenshot.jpg)

#####2引入头文件
```Objective-C
#import "YQGameCenterTool.h"
```
#####3使用

######检测GameCenter是否可用
Example：
```Objective-C
	if([YQGameCenterTool isAvailable]){
        //GameCenter可用"
    }else{
        //GameCenter不可用"
    }
```




