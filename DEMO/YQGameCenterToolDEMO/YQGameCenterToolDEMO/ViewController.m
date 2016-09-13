//
//  ViewController.m
//  YQGameCenterToolDEMO
//
//  Created by problemchild on 16/9/2.
//  Copyright © 2016年 ProblenChild. All rights reserved.
//
#define kLeaderboardID @"com.problenchild.YQIAPTest_leaderboard1"
#define kAchievementID @"com.problenchild.YQIAPTest_AchievementA"


#import "ViewController.h"

#import "YQGameCenterTool.h"

@import GameKit;

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UILabel *stateLab;
@property (weak, nonatomic) IBOutlet UIButton *checkEnableBTN;
@property (weak, nonatomic) IBOutlet UIButton *loginBTN;
@property (weak, nonatomic) IBOutlet UITextField *field;
@property (weak, nonatomic) IBOutlet UIButton *sendScoreBTN;
@property (weak, nonatomic) IBOutlet UIButton *GetLeaderBoardsBTN;
@property (weak, nonatomic) IBOutlet UIButton *ShowLeaderBoardBTN;
@property (weak, nonatomic) IBOutlet UIButton *downloadScoreBTN;
@property (weak, nonatomic) IBOutlet UIButton *getAchievmentBTN;
@property (weak, nonatomic) IBOutlet UIButton *getOnlineFriendesBTN;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    //禁用一些按钮
    self.sendScoreBTN.enabled         = NO;
    self.GetLeaderBoardsBTN.enabled   = NO;
    self.ShowLeaderBoardBTN.enabled   = NO;
    self.downloadScoreBTN.enabled     = NO;
    self.getAchievmentBTN.enabled     = NO;
    self.getOnlineFriendesBTN.enabled = NO;
}

//检测是否可用按钮按下
- (IBAction)checkEnableBTNTouched:(id)sender {
    if([YQGameCenterTool isAvailable]){
        self.stateLab.text = @"GameCenter可用";
    }else{
        self.stateLab.text = @"GameCenter不可用";
    }
}

//登录按钮按下
- (IBAction)LoginBTNTouched:(id)sender {
    
    self.loginBTN.enabled = NO;
    
    self.stateLab.text = @"正在登录";
    
    //先调用GCTool来用GC登陆
    [[YQGameCenterTool defaultTool] getGameCenterAccountWithBlock:^(bool success, UIViewController *viewcontroller)
     {
         
         //未登陆GameCenter，需要弹出GC的VC提示用户登陆
         if(viewcontroller)
         {
             //需要Present一个VC
             NSLog(@"VC Present");
             
             self.stateLab.text = @"需要弹出VC";
             
             //弹出GC的登录VC
             [self presentViewController:viewcontroller animated:YES completion:nil];
             
         }
         
         //同步走,判断GC的登陆状态
         //登陆状态改变会自动重走此方法
         if(success)
         {//GC已登陆成功
             NSLog(@"GC已登陆成功");
             
             NSLog(@"GC 的 ID 是:%@",[YQGameCenterTool defaultTool].Player.playerID);
             
             self.stateLab.text = @"登录成功";
             
             //允许提交分数
             self.sendScoreBTN.enabled         = YES;
             self.GetLeaderBoardsBTN.enabled   = YES;
             self.ShowLeaderBoardBTN.enabled   = YES;
             self.downloadScoreBTN.enabled     = YES;
             self.getAchievmentBTN.enabled     = YES;
             self.getOnlineFriendesBTN.enabled = YES;
             
             //允许重新登录
             self.loginBTN.enabled = YES;
         }
         else
         {//使用GC登录失败
             NSLog(@"使用GC登录失败");
             
             self.stateLab.text = @"登录失败";
             
             //允许重新登录
             self.loginBTN.enabled = YES;
         }
     }];
}
//获取所有排行榜
- (IBAction)GetAllLeaderBoardsBTNTouched:(id)sender {
    
    [[YQGameCenterTool defaultTool]GetAllLeaderBoardWithBlock:^(bool success, NSArray *array)
     {
         if(success){
             
             self.stateLab.text = @"已获取所有排行榜，信息已Log";
             NSLog(@"已获取所有排行榜:%@",array);
             
         }else{
             
             self.stateLab.text = @"获取所有排行榜失败";
             
         }
    }];
}

//显示排行榜
- (IBAction)ShowLeaderBoardBTNTouched:(id)sender {
    
    //得到VC
    UIViewController *vc = [[YQGameCenterTool defaultTool]GetLeaderBoardVCWithLeaderboardID:kLeaderboardID  andType:@"all"];
    
    //弹出VC
    [self presentViewController:vc animated:YES completion:nil];
    
    //监测排行榜VC的关闭
    [YQGameCenterTool defaultTool].LeaderBoardClosedBlock = ^(BOOL closed){
        [self dismissViewControllerAnimated:YES completion:nil];
    };
}



//提交分数按钮按下
- (IBAction)sendSocreBTNTouched:(id)sender {
    
    self.stateLab.text = @"正在上传分数";
    
    int socre = self.field.text.intValue;
    
    if(socre!=0){
        [[YQGameCenterTool defaultTool] setRaitScoreWithSocre:[NSNumber numberWithInt:socre]
                                             andLeaderboardID:kLeaderboardID
                                                    withBlock:^(bool success, NSError *error)
        {
            if(success){
                
                self.stateLab.text = @"上传分数成功";
                
            }else{
                
                self.stateLab.text = @"上传分数失败";
                
            }
        }];
    }
}

//收起键盘
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self.field resignFirstResponder];
}

//点击了手动下载分数按钮
- (IBAction)downloadScoreBTNTouched:(id)sender {
    
    //手动下载GameCenter排行榜的分数
    //type: today,week,all
    //begin: 从第几名开始
    //number:获取多少名用户
    [[YQGameCenterTool defaultTool]downloadLeaderBoardScoreWithLeaderBoardID:kLeaderboardID andType:@"all"
                                                                andBeginRank:@1
                                                                   andNumber:@10
                                                                   WithBlock:^(bool success, NSArray *array)
     {
         if(success){
             self.stateLab.text = @"分数下载成功，已Log";
             
             for (GKScore *obj in array) {
                 NSLog(@"玩家ID : %@",obj.player.playerID);
                 NSLog(@"玩家昵称 : %@",obj.player.displayName);
                 NSLog(@"时间  : %@",obj.date);
                 NSLog(@"带 单位的 分数  : %@",obj.formattedValue);
                 NSLog(@"分数  : %lld",obj.value);
                 NSLog(@"排名  : %ld",(long)obj.rank);
                 NSLog(@"------------------------");
             }
             
         }else{
             
             self.stateLab.text = @"分数下载失败";
             
         }
    }];
}
//模拟取得成就按钮按下
- (IBAction)GetAchievmentBTNTouched:(id)sender {
    
    [[YQGameCenterTool defaultTool]reportAchievment:kAchievementID
                              andPercentageComplete:101
                                          withBlock:^(bool success, NSError *error)
    {
        if(success){
            self.stateLab.text = @"成就已提交成功";
        }
    }];
}

//获取在线好友的按钮按下了
- (IBAction)getOnlineFriendesBTNTouched:(id)sender {
    
    [[YQGameCenterTool defaultTool] getOnlineFriendsWithArrBlock:^(bool success, NSArray *array)
    {
        if(success){
            
            self.stateLab.text = @"获取在线好友成功，已Log";
            
            for (GKPlayer *player in array) {
                NSLog(@"玩家ID : %@",player.playerID);
                NSLog(@"name : %@",player.displayName);
                NSLog(@"alisa  : %@",player.alias);
                NSLog(@"------------------------");
            }
        }else{
            self.stateLab.text = @"获取在线好友失败了";
        }
    }];
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
