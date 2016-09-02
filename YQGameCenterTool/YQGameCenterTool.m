//
//  YQGameCenterTool.m
//  YQGameCenterToolDEMO
//
//  Created by problemchild on 16/9/2.
//  Copyright © 2016年 ProblenChild. All rights reserved.
//

#import "YQGameCenterTool.h"

@implementation YQGameCenterTool

//单例
static YQGameCenterTool *staticTool;
/**
 *  单例
 *
 *  @return 单例
 */
+(YQGameCenterTool *)defaultTool{
    if(!staticTool){
        staticTool = [YQGameCenterTool new];
        [staticTool setup];
    }
    return staticTool;
}

-(GKLocalPlayer *)Player{
    if(!_Player){
        _Player = [GKLocalPlayer localPlayer];
    }
    return _Player;
}

/**
 *  初始化
 */
-(void)setup{
    
    //观察gamecenter登陆状态改变
    
    NSNotificationCenter* ns = [NSNotificationCenter defaultCenter];
    
    [ns addObserver:self
           selector:@selector(authenticationChanged)
               name:GKPlayerAuthenticationDidChangeNotificationName
             object:nil];
    
}

/**
 *  状态变化了
 */
- (void) authenticationChanged
{
    if ([GKLocalPlayer localPlayer].isAuthenticated) {
        NSLog(@"GameCenter状态变化，已登录");
    }
    else
    {
        NSLog(@"GameCenter状态变化，没有登录");
    }
}


/**
 *  请求GameCenter授权登陆,此方会自动响应
 *
 *  @param VCblock 如果需要弹出GC的一个VC的话，会调用此Block
 */
-(void)getGameCenterAccountWithBlock:(VCBlock)VCblock{
    
    //检查用于授权，如果没有登录则让用户登录到GameCenter(注意此事件设置之后或点击登录界面的取消按钮都会被调用)
    [self.Player setAuthenticateHandler:^(UIViewController * controller, NSError *error)
     {
         if ([[GKLocalPlayer localPlayer] isAuthenticated])
         {
             NSLog(@"GameCenter 已授权.");
             VCblock(YES,nil);
             
         }else{
             //注意：在设置中找到Game Center，设置其允许沙盒，否则controller为nil
             if(controller){
                 VCblock(NO,controller);
             }else{
                 VCblock(NO,nil);
             }
         }
     }];
}

/**
 *  向GameCenter提交分数(暂不启用)
 *
 *  @param score 分数
 */
-(void)setScore:(NSNumber *)score{
    //更新排行榜个数
    [GKLeaderboard loadLeaderboardsWithCompletionHandler:^(NSArray *leaderboards, NSError *error) {
        if (error) {
            NSLog(@"加载排行榜过程中发生错误,错误信息:%@",error.localizedDescription);
        }
        
        NSLog(@"leaderboards:%@",leaderboards);
        
        GKScore *scoreReporter = [[GKScore alloc] initWithLeaderboardIdentifier:((GKLeaderboard *)leaderboards.firstObject).identifier];
        scoreReporter.value = score.longLongValue;
        
        
        [GKScore reportScores:@[scoreReporter] withCompletionHandler:^(NSError * _Nullable error) {
            if (error != nil)
            {
                // handle the reporting error
                NSLog(@"GameCenter上传分数出错.");
                //If your application receives a network error, you should not discard the score.
                //Instead, store the score object and attempt to report the player’s process at
                //a later time.
            }else {
                NSLog(@"GameCenter上传分数成功");
            }
        }];
    }];
}

@end
