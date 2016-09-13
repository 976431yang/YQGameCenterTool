//
//  YQGameCenterTool.h
//  YQGameCenterToolDEMO
//
//  Created by problemchild on 16/9/2.
//  Copyright © 2016年 ProblenChild. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@import GameKit;

/**
 *  用于处理GameCenter的工具
 */
@interface YQGameCenterTool : NSObject

typedef void(^VCBlock)    (bool success,UIViewController *viewcontroller);
typedef void(^ArrBlock)   (bool success,NSArray *array);
typedef void(^BoolBlock)  (bool success,NSError *error);
typedef void(^LeaderBoardClosedBlock)(bool closed);

//GameCenter的用户
@property(nonatomic,strong)GKLocalPlayer *Player;


//单例
+(YQGameCenterTool *)defaultTool;

//检测是否可用
+ (BOOL) isAvailable;


//请求GameCenter授权登陆
//VCblock 如果需要弹出GC的一个VC的话，会调用此Block
-(void)getGameCenterAccountWithBlock:(VCBlock)VCblock;

//向GameCenter提交分数
-(void)setRaitScoreWithSocre:(NSNumber *)score
            andLeaderboardID:(NSString *)leaderboardID
                   withBlock:(BoolBlock)BoolBlock;

//得到所有的排行榜
-(void)GetAllLeaderBoardWithBlock:(ArrBlock)ArrBlock;

//得到排行榜VC
//type: today,week,all
-(UIViewController *)GetLeaderBoardVCWithLeaderboardID:(NSString *)leaderboardID
                                               andType:(NSString *)type;
//检测排行榜VC关闭了,会在排行榜关闭时触发
@property(nonatomic,strong)LeaderBoardClosedBlock LeaderBoardClosedBlock;

//手动下载GameCenter排行榜的分数
//type: today,week,all
//begin: 从第几名开始1~100
//number:获取多少名用户1~100
-(void)downloadLeaderBoardScoreWithLeaderBoardID:(NSString *)leaderBoardID
                                          andType:(NSString *)type
                                     andBeginRank:(NSNumber *)begin
                                        andNumber:(NSNumber *)number
                                        WithBlock:(ArrBlock)ArrBlock;

//报告玩家取得了成就
//identifier:成就ID
//percentComplete：游戏完成进度1~1000
-(void)reportAchievment:(NSString *)identifier
  andPercentageComplete:(double)percentComplete
              withBlock:(BoolBlock)BoolBlock;


//获取已登录用户好友列表
- (void)getOnlineFriendsWithArrBlock:(ArrBlock)ArrBlock;

@end
