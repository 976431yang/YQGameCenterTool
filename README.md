# YQGameCenterTool
####微博：畸形滴小男孩

###iOS端对GameCenter的封装

####集成方法：
#####1把文件拖到XCodeg工程中，并开启工程的GameCenter：
 ![image](https://github.com/976431yang/YQGameCenterTool/blob/master/DEMO/screenshot.jpg)

#####2引入头文件
```Objective-C
#import "YQGameCenterTool.h"
```
#####3使用

- [检测GameCenter是否可用](######检测GameCenter是否可用)
- [使用GameCenter登录](######使用GameCenter登录)
- [获取所有排行榜](######获取所有排行榜)
- [显示系统自带GameCenter排行榜VC](######显示系统自带GameCenter排行榜VC)
- [向排行榜提交分数](######向排行榜提交分数)
- [手动下载GameCenter排行榜的分数](######手动下载GameCenter排行榜的分数)
- [报告玩家取得了成就](######报告玩家取得了成就)
- [获取玩家在线的好友](######获取玩家 在线 的 好友)

######检测GameCenter是否可用
```Objective-C
	if([YQGameCenterTool isAvailable]){
        //GameCenter可用"
    }else{
        //GameCenter不可用"
    }
```
######使用GameCenter登录
```Objective-C

    [[YQGameCenterTool defaultTool] getGameCenterAccountWithBlock:^(bool success, UIViewController *viewcontroller)
     {
        //未登陆GameCenter，需要弹出GC的VC提示用户登陆
        if(viewcontroller)
        {
            //需要Present一个VC

            //弹出GC的登录VC
            [self presentViewController:viewcontroller animated:YES completion:nil];
        }
         
        //同步走,判断GC的登陆状态
        //登陆状态改变会自动重走此方法
        if(success)
        {//GC已登陆成功
            //NSLog(@"GC已登陆成功");
            //NSLog(@"GC 的 ID 是:%@",[YQGameCenterTool defaultTool].Player.playerID);
        }
        else
        {//使用GC登录失败
            //NSLog(@"使用GC登录失败");
        }
    }];
```
######获取所有排行榜
```Objective-C
	[[YQGameCenterTool defaultTool]GetAllLeaderBoardWithBlock:^(bool success, NSArray *array)
    {
        if(success){
            //NSLog(@"已获取所有排行榜:%@",array);
        }else{
            //获取所有排行榜失败
        }
    }];
```

######显示系统自带GameCenter排行榜VC
```Objective-C

	//1得到排行榜VC
    //type: today,week,all
    UIViewController *vc = [[YQGameCenterTool defaultTool]GetLeaderBoardVCWithLeaderboardID:kLeaderboardID  
    										    andType:@"all"];
    
    //2弹出VC
    [self presentViewController:vc animated:YES completion:nil];
    
    //3检测排行榜VC关闭了,会在排行榜关闭时触发
    [YQGameCenterTool defaultTool].LeaderBoardClosedBlock = ^(BOOL closed){
        [self dismissViewControllerAnimated:YES completion:nil];
    };
```

######向排行榜提交分数
```Objective-C

	//score:分数
    //leaderboardID:排行榜ID
    [[YQGameCenterTool defaultTool] setRaitScoreWithSocre:@80
                                         andLeaderboardID:kLeaderboardID
                                                withBlock:^(bool success, NSError *error)
    {
        if(success){
            //上传分数成功
        }else{
            //上传分数失败
        }
    }];
```

######手动下载GameCenter排行榜的分数
```Objective-C

	//type: today,week,all
    //begin: 从第几名开始1~100
    //number:获取多少名用户1~100
    [[YQGameCenterTool defaultTool]downloadLeaderBoardScoreWithLeaderBoardID:kLeaderboardID 
    								     andType:@"all"
                                 andBeginRank:@1
                             		andNumber:@10
                              		WithBlock:^(bool success, NSArray *array)
    {
        if(success){
            //分数下载成功，已Log;
            /* 
            for (GKScore *obj in array) {
                NSLog(@"玩家ID : %@",obj.player.playerID);
                NSLog(@"玩家昵称 : %@",obj.player.displayName);
                NSLog(@"时间  : %@",obj.date);
                NSLog(@"带 单位的 分数  : %@",obj.formattedValue);
                NSLog(@"分数  : %lld",obj.value);
                NSLog(@"排名  : %ld",(long)obj.rank);
                NSLog(@"------------------------");
            }
            */
        }else{
            //分数下载失败
        }
    }];
```

######报告玩家取得了成就
```Objective-C

	//identifier     :成就ID
    //percentComplete：游戏完成进度1~1000

    [[YQGameCenterTool defaultTool]reportAchievment:kAchievementID
                              andPercentageComplete:101
                                          withBlock:^(bool success, NSError *error)
    {
        if(success){
            //成就已提交成功
        }else{
        	//成就提交失败
        }
    }];
```

######获取玩家 在线 的 好友
```Objective-C

	[[YQGameCenterTool defaultTool] getOnlineFriendsWithArrBlock:^(bool success, NSArray *array)
    {
        if(success)
        {
            //获取在线好友成功，已Log
            /*
            for (GKPlayer *player in array) {
                NSLog(@"玩家ID : %@",player.playerID);
                NSLog(@"name : %@",player.displayName);
                NSLog(@"alisa  : %@",player.alias);
                NSLog(@"------------------------");
            }
            */
        }else{
            //获取在线好友失败了
        }
    }];
```






