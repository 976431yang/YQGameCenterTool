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

typedef void(^VCBlock)(bool success,UIViewController *viewcontroller);

/**
 *  单例
 *
 *  @return 单例
 */
+(YQGameCenterTool *)defaultTool;

/**
 *  请求GameCenter授权登陆
 *
 *  @param VCblock 如果需要弹出GC的一个VC的话，会调用此Block
 */
-(void)getGameCenterAccountWithBlock:(VCBlock)VCblock;

//向GameCenter提交分数
//暂不启用
//-(void)setScore:(NSNumber *)score;

/**
 *  GameCenter的用户
 */
@property(nonatomic,strong)GKLocalPlayer *Player;


@end
