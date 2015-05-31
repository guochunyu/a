//
//  MoreView.m
//  O了
//
//  Created by royasoft on 14-2-19.
//  Copyright (c) 2014年 QYB. All rights reserved.
//

#import "MoreView.h"
#import "MoreViewButton.h"
#import "MoreViewButton.h"
#import "RYAssetsPickerController.h"

#define action_tag_video 10010
#define action_tag_photo 10011

@implementation MoreView
- (id)initWithFrame:(CGRect)frame isgroup:(BOOL)isgroup titlearr:(NSArray *)ary
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor=[UIColor lightGrayColor];
        _moreArray=[[NSMutableArray alloc] initWithObjects:@"msg_camra_icon",@"msg_photo_icon",@"msg_icon_groupcall_nm.png",@"msg_icon_phone_nm.png",@"msg_icon_video_nm.png",nil];
        //        _view=[[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, 320, 190)];
        _view=[[UIScrollView alloc] initWithFrame:frame];
        _view.pagingEnabled=YES;//分页
        //        _view.contentSize=CGSizeMake(320, 150);
        _view.showsHorizontalScrollIndicator=NO;
        _view.showsVerticalScrollIndicator=NO;
        _view.backgroundColor=[UIColor colorWithRed:245/255.0 green:245/255.0 blue:245/255.0 alpha:1];
        _view.delegate=self;
        NSArray *titleArray;
        if(isgroup){
//            titleArray=@[@"拍照",@"图片",@"电话会议"];
            titleArray=ary;
        }
        else{
//            titleArray=@[@"拍照",@"图片",@"免费电话",@"视频聊天"];
            titleArray=ary;
        }
        for (int i = 0; i < titleArray.count; i++) {
            MoreViewButton *butt=[MoreViewButton buttonWithType:UIButtonTypeCustom];
            butt.buttonIndex=i;
            if(titleArray.count>3&&i>1){
                butt.buttonIndex++;
            }
            [butt addTarget:self action:@selector(moreButtClick:) forControlEvents:UIControlEventTouchUpInside];
            butt.frame = CGRectMake(23.5 + (i%4) * 76,20+(int)(i/4)*80, 45, 45);
            [butt setBackgroundImage:[UIImage imageNamed:[_moreArray objectAtIndex:butt.buttonIndex]] forState:UIControlStateNormal];
            butt.contentEdgeInsets=UIEdgeInsetsMake(43, 0, 0, 0);
            [_view addSubview:butt];
            
            UIMyLabel *label=[[UIMyLabel alloc] init];
            label.frame=CGRectMake(butt.frame.origin.x-3, butt.frame.origin.y+butt.frame.size.height+5, butt.frame.size.width+6, 20);
            label.font=[UIFont systemFontOfSize:12];
            label.text=titleArray[i];
            label.textColor=[UIColor colorWithRed:102/255.0 green:102/255.0 blue:102/255.0 alpha:1];
            [_view addSubview:label];
            
        }
        
        _morePageControl=[[UIPageControl alloc] initWithFrame:CGRectMake(110, _view.frame.size.height-25, 100, 20)];
        [_morePageControl addTarget:self action:@selector(pageChange:) forControlEvents:UIControlEventValueChanged];
        _morePageControl.numberOfPages=1;
        _morePageControl.currentPage=0;
        [self addSubview:_view];
//        [self addSubview:_morePageControl];
    }
    return self;
}

- (void)pageChange:(id)sender {
    _morePageControl.currentPage=_view.contentOffset.x/320;
    [_morePageControl updateCurrentPageDisplay];
}

-(void)moreButtClick:(id)sender{
    //    int i = ((FaceButton*)sender).buttonIndex;
    //moreButton点击时ActionSheet弹出，自身下去
    
    
    MoreViewButton *butt=(MoreViewButton *)sender;
    
    long i=butt.buttonIndex;
    
    if (self.moreButtClick) {
        self.moreButtClick(i);
    }
    
}

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect
 {
 // Drawing code
 }
 */

@end
