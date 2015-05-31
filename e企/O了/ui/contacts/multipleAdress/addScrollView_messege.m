//
//  addScrollView_messege.m
//  O了
//
//  Created by macmini on 14-02-11.
//  Copyright (c) 2014 QYB. All rights reserved.
//


#define SEARCH_HEIGHT 40 //tableView头部高度
#define SCROLLVIEW_ICON_MARGIN 7    //scrollView的图标间距
#define SCROLLVIEW_ICON 11
#define SECTION_MAX_ROW 1000    //每组最大行数
#define ANIMATION_DURATION 0.2  //动画持续时间

#import "addScrollView_messege.h"
#import "menber_info.h"

@implementation addScrollView_messege

@synthesize scrollView = _scrollView,okButtonTitle;
static addScrollView_messege *addscrollView_contacts;
+(addScrollView_messege *)sharedInstanse{
    if (addscrollView_contacts == nil) {
        addscrollView_contacts = [[addScrollView_messege alloc]init];
        addscrollView_contacts.array_addcontact = [[NSMutableArray alloc] init];
        addscrollView_contacts.allmenber = [[NSMutableArray alloc]init];
    }
    return addscrollView_contacts;
}

#pragma mark - 自定义的方法
#pragma mark 初始化
- (void)show
{
    //toolbar设置
    if (_scrollView == nil) {
        CGFloat widthScreen=[UIScreen mainScreen].bounds.size.width;
        CGRect frameToolbar=self.navCT.toolbar.frame;
        
        if (!okButtonTitle) {
            okButtonTitle=@"确定";
            
        }
        NSString *sizeStr=[NSString stringWithFormat:@"%@(11)",okButtonTitle];
        CGSize labelSize=[sizeStr sizeWithFont:[UIFont systemFontOfSize:12] constrainedToSize:CGSizeMake(150, 8000) lineBreakMode:NSLineBreakByCharWrapping];
        
        //scrollView设置
        _scrollView=[[UIScrollView alloc]init];
        _scrollView.frame=CGRectMake(0, 0, widthScreen-(labelSize.width+5)-4, frameToolbar.size.height);
        /*
         //默认空白视图
         CGFloat iconHeight=frameToolbar.size.height-2*SCROLLVIEW_ICON_MARGIN;
         UIImageView *imageViewEmpty=[[UIImageView alloc]initWithFrame:CGRectMake(SCROLLVIEW_ICON_MARGIN, SCROLLVIEW_ICON_MARGIN, iconHeight, iconHeight)];
         imageViewEmpty.image=[UIImage imageNamed:@"tool_empty_member.png"];
         imageViewEmpty.tag=INT_MAX;
         //        DDLogInfo(@"%d",INT_MAX);
         [_scrollView addSubview:imageViewEmpty];
         */
        //toolBar的确定按钮设置
        _btnSender=[UIButton buttonWithType:UIButtonTypeCustom];
        _btnSender.enabled = NO;
        _btnSender.titleLabel.font=[UIFont systemFontOfSize:12];
        
        
        [_btnSender setTitle:okButtonTitle forState:UIControlStateNormal];
        
        _btnSender.frame=CGRectMake(_scrollView.frame.size.width - 2, (_scrollView.frame.size.height-25)/2, labelSize.width+5, 25);
        [_btnSender setBackgroundImage:[UIImage imageNamed:@"btn_choice_unable.png"] forState:UIControlStateDisabled];
        [_btnSender setBackgroundImage:[UIImage imageNamed:@"btn_choice_nm.png"] forState:UIControlStateNormal];
        [_btnSender setBackgroundImage:[UIImage imageNamed:@"btn_choice_pre.png"] forState:UIControlStateHighlighted];
        [_btnSender addTarget:self action:@selector(addcontactAction) forControlEvents:UIControlEventTouchUpInside];
        //    _btnSender.enabled=NO;
        
    }
    [self.navCT.toolbar addSubview:_scrollView];
    [self.navCT.toolbar addSubview:_btnSender];
    self.navCT.toolbarHidden=NO;
    
    
    //navigation设置
}

//添加到本地通讯录
-(void)addcontactAction{
    //    NSMutableArray *mutarr = [[NSMutableArray alloc]init];
    //    DDLogInfo(@"allmenber::%@",self.allmenber);
    //    for (EmployeeModel *menb in self.allmenber) {
    //        NSString *selfNumber=[[NSUserDefaults standardUserDefaults] objectForKey:MOBILEPHONE];
    //        if (![menb.phone isEqualToString:selfNumber]) {
    //            NSString *str = [NSString stringWithFormat:@"%d",menb.ID];
    //            if ([self.array_addcontact containsObject:str]) {
    //
    //                [mutarr addObject:menb];
    //            }
    //        }
    //    }
    //    _array_addcontact
    if([_allmenber count]+_nowcount>200){
        UIAlertView *toomuch=[[UIAlertView alloc]initWithTitle:@"提醒" message:@"群成员数量不能超过200" delegate:nil cancelButtonTitle:@"确认" otherButtonTitles: nil];
        [toomuch show];
    }else{
        for (int i=0; i<self.allmenber.count;i++) {
            EmployeeModel *model=[self.allmenber objectAtIndex:i];
            if (model.leaderType==1) {
                //model.phone=@"";
            }
        }
        
        [self.delegate SendArrayID:self.allmenber];
        [self releaseInstanse];
    }
}

-(void)releaseInstanse
{
    addscrollView_contacts = nil;
}

#pragma mark 在ScrollView中添加视图Button
- (void)addSubViewWithPhone:(NSString *)phone withImageName:(NSString *)imageName ToScrollView:(UIScrollView *)scrollView withUrl:(NSURL *)url
{
    if (![self.array_addcontact containsObject:phone]) {
        [self.array_addcontact addObject:phone];
    }
    
    //移除scrollview中不是button类的视图
    NSMutableArray *subViews=[NSMutableArray array];
    for (UIView *view in scrollView.subviews) {
        if ([view isKindOfClass:[UIButton class]]) {
            [subViews addObject:view];
        }
    }
    
    CGRect scrollFrame=scrollView.frame;
    CGFloat iconHeight=scrollFrame.size.height-2*SCROLLVIEW_ICON_MARGIN;
    //添加button
    AddGroupScrollButt *button = [AddGroupScrollButt buttonWithType:UIButtonTypeCustom];
    UIImageView *imageButton = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, iconHeight, iconHeight)];
    [button setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
    button.layer.masksToBounds = YES;
    button.layer.cornerRadius = iconHeight * 0.5;
    //创建群聊设置button图片
    if (url) {
        [imageButton setImageWithURL:url placeholderImage:[UIImage imageNamed:@"address_icon_personm.png"]];
        [button addSubview:imageButton];
    }
    button.phone=phone;
    //    [button setImage:[UIImage imageNamed:imageName]];
  //  [button addTarget:self action:@selector(dropSelectUser:) forControlEvents:UIControlEventTouchUpInside];
    
    if (subViews.count<=0) {
        button.frame=CGRectMake(SCROLLVIEW_ICON, SCROLLVIEW_ICON_MARGIN, iconHeight, iconHeight);
    }else{
        CGRect frame=[subViews.lastObject frame];
        button.frame=CGRectMake(frame.origin.x+frame.size.width+SCROLLVIEW_ICON, SCROLLVIEW_ICON_MARGIN, iconHeight, iconHeight);
    }
    //[scrollView addSubview:button];
    UIImageView *emptyView=(UIImageView *)[scrollView viewWithTag:INT_MAX];
    [scrollView insertSubview:button atIndex:[subViews indexOfObject:emptyView]];
    scrollView.contentSize=CGSizeMake(button.frame.origin.x+button.frame.size.width+SCROLLVIEW_ICON+iconHeight + 10, scrollView.bounds.size.height);
    //动画设置
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:ANIMATION_DURATION];
    //偏移量设置
    CGFloat exceptEmptySize=scrollView.contentSize.width-SCROLLVIEW_ICON-iconHeight;
    if (exceptEmptySize>scrollView.bounds.size.width) {
        scrollView.contentOffset=CGPointMake(exceptEmptySize-scrollView.bounds.size.width, 0);
    }
    emptyView.transform=CGAffineTransformTranslate(emptyView.transform, SCROLLVIEW_ICON_MARGIN+iconHeight, 0);
    //结束动画
    [UIView commitAnimations];
    //确定按钮数量变换
    _btnSender.enabled=YES;
    [_btnSender setTitle:[NSString stringWithFormat:@"%@(%d)",okButtonTitle,[self.array_addcontact count]] forState:UIControlStateNormal];
    //    for (UIView *view in scrollView.subviews) {
    //        DDLogInfo(@"%s,%d",object_getClassName(view),view.tag);
    //    }
}

-(void)dropSelectUser:(AddGroupScrollButt *)sender{
    //    DDLogInfo(@"enderL::%d",sender.tag);
    for (EmployeeModel *menb in self.allmenber) {
        if ([menb.phone isEqualToString:sender.phone]) {
            [self.allmenber removeObject:menb];
            break;
        }
    }
    [self removeSubViewWithPhone:sender.phone FromScrollView:self.scrollView];
    UITableViewController *tabVC= [self.navCT.viewControllers lastObject];
    
    //    DDLogInfo(@"searchDisp::%@",NSStringFromClass([tabCT.view class]));
    UITableView *tableView = nil;
    for (UIView *view in tabVC.view.subviews) {
        if (IS_IOS_7) {
            if ([NSStringFromClass([view class]) isEqualToString:@"UISearchDisplayControllerContainerView"]) {
                tableView =[[[self.navCT.viewControllers lastObject] searchDisplayController] searchResultsTableView];
                
            }
        }else{
            if ([NSStringFromClass([view class]) isEqualToString:@"UISearchResultsTableView"]) {
                tableView =[[[self.navCT.viewControllers lastObject] searchDisplayController] searchResultsTableView];
                
            }
        }
        
        //          DDLogInfo(@"searchDisp::%@",NSStringFromClass([view class]));
    }
    if (tableView) {
    
        [tableView reloadData];
    }else{
        if ([NSStringFromClass([tabVC.view class]) isEqualToString:@"UITableView"]) {
            [(UITableView *)tabVC.view reloadData];
        }
    }
    
}

//

#pragma mark 从ScrollView中移除view
- (void)removeSubViewWithPhone:(NSString *)phone FromScrollView:(UIScrollView *)scrollView
{
    if ([self.array_addcontact containsObject:phone]) {
        [self.array_addcontact removeObject:phone];
    }
    //移除ScrollView中存在的Button
    NSArray *buttons=[scrollView subviews];
    CGRect removeViewRect=CGRectZero;
    //动画效果
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:ANIMATION_DURATION];
    //button变幻
    for (AddGroupScrollButt *butt in buttons) {
        if ([butt isKindOfClass:[AddGroupScrollButt class]] && [butt.phone isEqualToString:phone]) {
            [butt removeFromSuperview];
            removeViewRect=butt.frame;
            continue;
        }
        if(!CGRectEqualToRect(removeViewRect, CGRectZero)&&[butt isKindOfClass:[AddGroupScrollButt class]]){
            butt.transform=CGAffineTransformTranslate(butt.transform,-(removeViewRect.size.width+SCROLLVIEW_ICON), 0);
        }
    }
    //空白头像变幻
    UIView *emptyView=[scrollView viewWithTag:INT_MAX];
    emptyView.transform=CGAffineTransformTranslate(emptyView.transform, -emptyView.frame.size.width-SCROLLVIEW_ICON, 0);
    //contentSize重设
    scrollView.contentSize=CGSizeMake(scrollView.contentSize.width-removeViewRect.size.width-SCROLLVIEW_ICON,scrollView.contentSize.height);
    //结束动画
    [UIView commitAnimations];
    //确定按钮数量变换
    if ([self.array_addcontact count]==0) {
        _btnSender.enabled=NO;
        [_btnSender setTitle:okButtonTitle forState:UIControlStateDisabled];
    }else{
        _btnSender.enabled=YES;
        [_btnSender setTitle:[NSString stringWithFormat:@"%@(%d)",okButtonTitle,[self.array_addcontact count]] forState:UIControlStateNormal];
    }
}


@end
