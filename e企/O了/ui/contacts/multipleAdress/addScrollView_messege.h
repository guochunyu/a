//
//  addScrollView_messege.h
//  O了
//
//  Created by macmini on 14-02-11.
//  Copyright (c) 2014 QYB. All rights reserved.
//

#import "addScrollView_messege.h"
#import "AddGroupScrollButt.h"

@protocol addscrollViewDelegate <NSObject>
@optional
-(void)SendArrayID:(NSMutableArray *)array_addId;

@end

@interface addScrollView_messege : NSObject{
    UIButton *_btnSender;
    NSMutableDictionary *_dictionarySelectUser;   ///<要添加的群聊用户
}


@property (nonatomic,strong)UINavigationController *navCT;
@property (nonatomic, strong)NSMutableArray *array_addcontact;
@property (nonatomic, strong)UIScrollView *scrollView;
@property (nonatomic, strong)NSMutableArray *allmenber;
@property(nonatomic,copy)NSString *okButtonTitle;
@property(nonatomic,assign)BOOL isSmsInvitation;
@property int nowcount;

@property (nonatomic, weak) id<addscrollViewDelegate>delegate;

+(addScrollView_messege *)sharedInstanse;
- (void)show;

-(void)releaseInstanse;

- (void)addSubViewWithPhone:(NSString *)phone withImageName:(NSString *)imageName ToScrollView:(UIScrollView *)scrollView withUrl:(NSURL *)url;
- (void)removeSubViewWithPhone:(NSString *)phone FromScrollView:(UIScrollView *)scrollView;
@end
