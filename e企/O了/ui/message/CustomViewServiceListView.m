//
//  CustomViewServiceListView.m
//  O了
//
//  Created by roya-7 on 14-9-18.
//  Copyright (c) 2014年 QYB. All rights reserved.
//

#import "CustomViewServiceListView.h"
//#import <QuartzCore/QuartzCore.h>
#import "UIMyLabel.h"
#import "CustomServiceViewButton.h"
#import "UIButton+WebCache.h"

#import "CustomServiceCell.h"

#define top_margin 0 ///<上下边距



@interface CustomViewServiceListView(){
    NSArray *_dataArray;
}
@end
@implementation CustomViewServiceListView
-(id)initWithFrame:(CGRect)frame{
    self=[super initWithFrame:frame];
    if (self) {
        
        [self loadButtonView];
        
    }
    return self;
}
-(void)loadButtonView{
    
    //    self.backgroundColor=[UIColor redColor];
    
    [self setBackgroundColor:[UIColor whiteColor]];
    
    [self.layer setMasksToBounds:YES];
//    self.layer.shouldRasterize=YES;
    self.layer.cornerRadius=5;
//    [self loadTable];
    
    self.userInteractionEnabled=YES;

}
-(void)loadTable{
    if(!_myTable){
        _myTable=[[TouchTable alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height) style:UITableViewStylePlain];
        _myTable.dataSource=self;
        _myTable.delegate=self;
        _myTable.scrollEnabled=NO;
        _myTable.userInteractionEnabled=YES;
        
        if (IS_IOS_7) {
            _myTable.separatorInset=UIEdgeInsetsZero;
//            [_myTable setSeparatorInset:UIEdgeInsetsMake(0, 67, 0, 0)];
        }
        
        [self addSubview:_myTable];
        /*
        UILongPressGestureRecognizer *longPressGesture=[[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressGesture:)];
        [_myTable addGestureRecognizer:longPressGesture];
         */
    }
}

#pragma mark - 单元格长按
//显示菜单
-(BOOL) canPerformAction:(SEL)action withSender:(id)sender{
    if (action == @selector(myTrainsmit:) || action == @selector(myDelete:) || action == @selector(myMore:)) {
        return YES;
    }
    return NO;
}
-(void)longPressGesture:(UILongPressGestureRecognizer *)longPressGesture{
    
    
    
    CGPoint p = [longPressGesture locationInView:_myTable];
    NSIndexPath * indexPath = [_myTable indexPathForRowAtPoint:p];
    UITableViewCell * cell = [_myTable cellForRowAtIndexPath:indexPath];

    if ((p.y > (cell.frame.origin.y + cell.frame.size.height))) {
        return;
    }
    //单元格长按
    
    if(longPressGesture.state == UIGestureRecognizerStateBegan){
        [cell becomeFirstResponder];
        
        UIMenuItem *myTrainsmit = [[UIMenuItem alloc] initWithTitle:@"转发" action:@selector(myTrainsmit:)];
        UIMenuItem *myDelete = [[UIMenuItem alloc] initWithTitle:@"删除" action:@selector(myDelete:)];
        
        UIMenuItem *myMore = [[UIMenuItem alloc] initWithTitle:@"更多" action:@selector(myMore:)];
        UIMenuController *menu = [UIMenuController sharedMenuController];
        
        NSMutableArray  *menuArray=[[NSMutableArray alloc] init];

        NSArray *authoArray=[[NSUserDefaults standardUserDefaults] objectForKey:@"authority_type"];
        for (NSDictionary *dict in authoArray) {
            NSString *authorityId=dict[@"authorityId"];
            if ([authorityId isEqualToString:@"delete"]) {
                [menuArray addObject:myDelete];
            }else if ([authorityId isEqualToString:@"zf"]){
                [menuArray addObject:myTrainsmit];
            }else if ([authorityId isEqualToString:@"pl_manage"]){
                [menuArray addObject:myMore];
            }
        }
        
//        [menu setMenuItems:[NSArray arrayWithObjects:menuArray,nil]];
        [menu setMenuItems:menuArray];
        [menu setTargetRect:cell.frame inView:cell.superview];
        [menu setMenuVisible:YES animated:YES];
    }


}
-(void)myTrainsmit:(id)sender{
    if (self.menuClick) {
        self.menuClick(myTransmit);
    }
}
-(void)myDelete:(id)sender{
    if (self.menuClick) {
        self.menuClick(myDelete);
    }
}
-(void)myMore:(id)sender{
    if (self.menuClick) {
        self.menuClick(myMore);
    }
}
#pragma mark - 设置数据
-(void)setNd:(NotesData *)nd{
    if (nd) {
        _nd=nd;
    }
    
    
    NSError *error=nil;
    
    NSXMLElement *x_parse=[[NSXMLElement alloc] initWithXMLString:nd.sendContents error:&error];
    
    if (error) {
        DDLogInfo(@"解析出错,error:%@",error);
    }
    NSArray *articleArray=[[x_parse elementForName:@"article"] elementsForName:@"mediaarticle"];
    
    _dataArray=articleArray;
    
    CGRect rect=self.frame;
    rect.size.height=(articleArray.count-1)*65+150;
    self.frame=rect;
    rect.origin.x=0;
    rect.origin.y=0;
    
    [self loadTable];

    _myTable.frame=rect;
    [_myTable reloadData];
    
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _dataArray.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSXMLElement *serverNewElement=_dataArray[indexPath.row];
    
    if (indexPath.row==0) {
        //第一个
        static NSString *cellIdentifier=@"CustomServiceFirstCell";
        CustomServiceFirstCell *cell=[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (!cell) {
            cell=[[[NSBundle mainBundle] loadNibNamed:@"CustomServiceCell" owner:self options:nil] lastObject];
        }
        
        
        [cell.bigImageView setImageWithURL:[NSURL URLWithString:[[serverNewElement elementForName:@"original_link"] stringValue]] placeholderImage:nil];
        cell.bigImageView.frame=CGRectMake(10, 6, 270, 135);
        cell.titleText=[[serverNewElement elementForName:@"title"] stringValue];
        
        return cell;
    }else{
        static NSString *cellIdentifier=@"CustomServiceOtherCell";
        CustomServiceOtherCell *cell=[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (!cell) {
            
            NSArray *cellArray=[[NSBundle mainBundle] loadNibNamed:@"CustomServiceCell" owner:self options:nil];
            cell=[cellArray objectAtIndex:cellArray.count-2];
            
        }
        [cell.detailImage setImageWithURL:[NSURL URLWithString:[[serverNewElement elementForName:@"original_link"] stringValue]] placeholderImage:nil];
        cell.titelLabel.text=[[serverNewElement elementForName:@"title"] stringValue];
        return cell;
    }
    
    return nil;

    
    
}
-(void)buttClick{
    DDLogInfo(@"butt");
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (indexPath.row==0) {
        return 150.f;
    }
    
    return 65;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSXMLElement *serverNewElement=_dataArray[indexPath.row];
    if (self.tabelDidClick) {
        self.tabelDidClick(tableView,indexPath,serverNewElement);
    }
}
- (void)tableView:(UITableView *)tableView
     touchesBegan:(NSSet *)touches
        withEvent:(UIEvent *)event{
    DDLogInfo(@"点击");
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
