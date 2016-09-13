//
//  YQGameCenterTool.m
//  YQGameCenterToolDEMO
//
//  Created by problemchild on 16/9/2.
//  Copyright © 2016年 ProblenChild. All rights reserved.
//

#import "YQGameCenterTool.h"

@interface YQGameCenterTool ()<GKGameCenterControllerDelegate>

@end

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

+ (BOOL) isAvailable
{
    Class gcClass = (NSClassFromString(@"GKLocalPlayer"));
    NSString *reqSysVer = @"4.1";
    NSString *currSysVer = [[UIDevice currentDevice] systemVersion];
    BOOL osVersionSupported = ([currSysVer compare:reqSysVer options:NSNumericSearch] != NSOrderedAscending);
    
    return (gcClass && osVersionSupported);
}

-(GKLocalPlayer *)Player{
    if(!_Player){
        _Player = [GKLocalPlayer localPlayer];
    }
    return _Player;
}


//初始化
-(void)setup{
    
    //观察gamecenter登陆状态改变
    
    NSNotificationCenter* ns = [NSNotificationCenter defaultCenter];
    
    [ns addObserver:self
           selector:@selector(authenticationChanged)
               name:GKPlayerAuthenticationDidChangeNotificationName
             object:nil];
    
}


//状态变化了
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



//请求GameCenter授权登陆,此方会自动响应
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


//向GameCenter提交分数
-(void)setRaitScoreWithSocre:(NSNumber *)score
            andLeaderboardID:(NSString *)leaderboardID
                   withBlock:(BoolBlock)BoolBlock
{
    GKScore *scoreReporter = [[GKScore alloc] initWithLeaderboardIdentifier:leaderboardID];
    scoreReporter.value = score.longLongValue;
    
    [GKScore reportScores:@[scoreReporter] withCompletionHandler:^(NSError * _Nullable error) {
        if (error != nil)
        {
            NSLog(@"GameCenter上传分数出错.");
            
            BoolBlock(NO,error);
            
        }else {
            NSLog(@"GameCenter上传分数成功");
            
            BoolBlock(YES,nil);
        }
    }];
}

//得到所有的排行榜
-(void)GetAllLeaderBoardWithBlock:(ArrBlock)ArrBlock
{
    [GKLeaderboard loadLeaderboardsWithCompletionHandler:^(NSArray *leaderboards, NSError *error)
    {
        if (error)
        {
            NSLog(@"加载排行榜过程中发生错误,错误信息:%@",error.localizedDescription);
            ArrBlock(NO,nil);
        }
        
        NSLog(@"leaderboards:%@",leaderboards);
        ArrBlock(YES,leaderboards);
    }];
}

//得到排行榜的VC
-(UIViewController *)GetLeaderBoardVCWithLeaderboardID:(NSString *)leaderboardID
                                               andType:(NSString *)type
{
    GKGameCenterViewController *gameView = [[GKGameCenterViewController alloc] init];
    
    gameView.gameCenterDelegate = self;
    
    [gameView setLeaderboardIdentifier:leaderboardID];
    if([type isEqualToString:@"today"]){
        [gameView setLeaderboardTimeScope:GKLeaderboardTimeScopeToday];
    }else if([type isEqualToString:@"week"]){
        [gameView setLeaderboardTimeScope:GKLeaderboardTimeScopeWeek];
    }else if([type isEqualToString:@"all"]){
        [gameView setLeaderboardTimeScope:GKLeaderboardTimeScopeAllTime];
    }
    return gameView;
}

-(void)gameCenterViewControllerDidFinish:(GKGameCenterViewController *)gameCenterViewController
{
    self.LeaderBoardClosedBlock(YES);
}


//手动下载GameCenter排行榜的分数
//type: today,week,all
//begin: 从第几名开始
//number:获取多少名用户
-(void)downloadLeaderBoardScoreWithLeaderBoardID:(NSString *)leaderBoardID
                                         andType:(NSString *)type
                                    andBeginRank:(NSNumber *)begin
                                       andNumber:(NSNumber *)number
                                       WithBlock:(ArrBlock)ArrBlock
{
    GKLeaderboard *leaderboardRequest = [[GKLeaderboard alloc] init];
    leaderboardRequest.playerScope    = GKLeaderboardPlayerScopeGlobal;
    if([type isEqualToString:@"today"]){
        leaderboardRequest.timeScope = GKLeaderboardTimeScopeToday;
    }else if([type isEqualToString:@"week"]){
        leaderboardRequest.timeScope = GKLeaderboardTimeScopeWeek;
    }else if([type isEqualToString:@"all"]){
        leaderboardRequest.timeScope = GKLeaderboardTimeScopeAllTime;
    }
    
    leaderboardRequest.range          = NSMakeRange([begin integerValue],
                                                    [number integerValue]);
    leaderboardRequest.identifier     = leaderBoardID;
    
    [leaderboardRequest loadScoresWithCompletionHandler: ^(NSArray *scores, NSError *error) {
        if (error != nil){
            NSLog(@"下载分数失败：%@",error);
            ArrBlock(NO,nil);
        }
        if (scores != nil){
            
            NSArray *tempScore = [NSArray arrayWithArray:leaderboardRequest.scores];
            
            ArrBlock(YES,tempScore);
        }
    }];
}

//报告玩家取得了成就
-(void)reportAchievment:(NSString *)identifier
  andPercentageComplete:(double)percentComplete
              withBlock:(BoolBlock)BoolBlock
{
    GKAchievement *achievement = [[GKAchievement alloc] initWithIdentifier:identifier];
    
    [achievement setPercentComplete:percentComplete];
    
    [GKAchievement reportAchievements:@[achievement] withCompletionHandler:^(NSError * _Nullable error)
    {
        if(error != nil){
            NSLog(@"error:%@", [error localizedDescription]);
            BoolBlock(NO,error);
        }else{
            NSLog(@"提交成就成功");
            BoolBlock(YES,nil);
        }
    }];
}

//获取已登录用户好友列表
- (void)getOnlineFriendsWithArrBlock:(ArrBlock)ArrBlock
{
    [self.Player loadFriendPlayersWithCompletionHandler:^(NSArray<GKPlayer *> * _Nullable friendPlayers, NSError * _Nullable error)
    {
        if (error == nil)
        {
            ArrBlock(YES,friendPlayers);
        }
        else
        {
            NSLog(@"获取已登录的好友列表失败：%@",error);
            ArrBlock(NO,nil);
        }
    }];
}

@end
