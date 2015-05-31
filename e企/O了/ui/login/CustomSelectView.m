//
//  CustomSelectView.m
//  e企
//
//  Created by ； on 14-11-3.
//  Copyright (c) 2014年 QYB. All rights reserved.
//

#import "CustomSelectView.h"

#define ROW_HEIGHT 67
#define ROW_TITLE_HEIGHT 50
#define ROW_WIDTH 290

@implementation CustomSelectView

@synthesize nameLabel=_nameLabel;
@synthesize nameLabel1=_nameLabel1;
@synthesize companyNameLabel=_companyNameLabel;
@synthesize companyNameLabel1=_companyNameLabel1,dataDic=_dataDic;


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self hideMoreLine];
    }
    return self;
}
- (id)initWithTitle:(NSString *)title  delegate:(id<CustomSelectViewDelegate>)delegate data:(NSDictionary*)dic;
{
    NSArray * array = dic[@"uinfo"][@"cid"];
    int companyNumber = array.count;
    if (companyNumber > 4) {
        companyNumber = 4;
    }
    self=[self initWithFrame:CGRectMake(0, 0, ROW_WIDTH, ROW_TITLE_HEIGHT + ROW_HEIGHT * companyNumber)];
    self.dataDic = (NSDictionary * )dic;
    if (self) {
        
        _deledate=delegate;
    _contentView=[[UIView alloc]initWithFrame:CGRectMake(0, 0, ROW_WIDTH, ROW_TITLE_HEIGHT + ROW_HEIGHT * companyNumber)];
        _contentView.layer.cornerRadius=5;
        _contentView.clipsToBounds=YES;
        [self addSubview:_contentView];
        
        self.title=title;
        _scrollTableView=[[UITableView alloc]initWithFrame:_contentView.bounds style:UITableViewStylePlain];
        self.scrollTableView.delegate = self;
        self.scrollTableView.dataSource = self;
        [_contentView addSubview:self.scrollTableView];
        dataDic=dic;

    }
    return self;
}
-(void)hideMoreLine
{
    UIView *hide_line = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.scrollTableView.frame.size.width, 1)];
    hide_line.backgroundColor = [UIColor whiteColor];
    
  //  [self.scrollTableView setTableFooterView:hide_line];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.scrollTableView setSeparatorColor:[UIColor clearColor]];
    static int height=0;
    if (indexPath.row==0) {
        height=ROW_TITLE_HEIGHT;
    }else{
        height=ROW_HEIGHT;
    }
    return height;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSArray * dataArray=dataDic[@"uinfo"][@"cid"];
    return dataArray.count+1;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
        cell.selectionStyle=UITableViewCellSelectionStyleNone;
    }else{
        //删除cell的所有子视图
        while ([cell.contentView.subviews lastObject] != nil)
        {
            [(UIView*)[cell.contentView.subviews lastObject] removeFromSuperview];
        }
    }
    if (indexPath.row==0) {
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, ROW_WIDTH, ROW_TITLE_HEIGHT)];
        titleLabel.text = self.title;
        titleLabel.textColor = UIColorFromRGB(0x333333);
        DDLogInfo(@"%@",self.title);
      
        titleLabel.textAlignment = NSTextAlignmentLeft;
       
        UIView * line_view1 =[[UIView alloc]initWithFrame:CGRectMake(0,ROW_TITLE_HEIGHT - 0.5, ROW_WIDTH,0.5)];
        line_view1.backgroundColor=UIColorFromRGB(0xdcdcdc);
        [cell.contentView addSubview:line_view1];
         [cell.contentView addSubview:titleLabel];
    }else{
//       企业的logo
        NSArray * companyNameArray=dataDic[@"uinfo"][@"cname"];
        NSArray * companyPositionArray=dataDic[@"uinfo"][@"city"];
        NSArray * elogoArray=dataDic[@"uinfo"][@"clogo"];
        UIImageView * elogo=[[UIImageView alloc]initWithFrame:CGRectMake(15, 15, 40, 40)];
        elogo.layer.cornerRadius=20;
        elogo.clipsToBounds=YES;
        NSString * elogoUrl=[elogoArray objectAtIndex:indexPath.row-1];
        if (elogoUrl) {
            if ((NSNull *)elogoUrl!=[NSNull null]) {
                [elogo setImageWithURL:[NSURL URLWithString:elogoUrl] placeholderImage:[UIImage imageNamed:@"58.png"]];
            }else{
                elogo.image=[UIImage imageNamed:@"58.png"];
            }
        }
        [cell.contentView addSubview:elogo];
        NSString * city_name=[companyPositionArray objectAtIndex:indexPath.row-1];
        if ([city_name isEqualToString:@""]) {
            UILabel * companyLable=[[UILabel alloc]initWithFrame:CGRectMake(70, 25, 200, 20)];
            companyLable.font=[UIFont systemFontOfSize:15];
            companyLable.textColor = UIColorFromRGB(0x333333);
            companyLable.text=[companyNameArray objectAtIndex:indexPath.row-1];
            [cell.contentView addSubview:companyLable];
        }else{
            UILabel * companyLable=[[UILabel alloc]initWithFrame:CGRectMake(70, 15, 200, 20)];
            companyLable.font=[UIFont systemFontOfSize:15];
            companyLable.textColor = UIColorFromRGB(0x333333);
            companyLable.text=[companyNameArray objectAtIndex:indexPath.row-1];
            [cell.contentView addSubview:companyLable];
            
            UILabel * positionLable=[[UILabel alloc]initWithFrame:CGRectMake(70, 40, 200, 10)];
            positionLable.font=[UIFont systemFontOfSize:13];
            positionLable.text=[companyPositionArray objectAtIndex:indexPath.row-1];
            positionLable.textColor = UIColorFromRGB(0x999999);
            [cell.contentView  addSubview:positionLable];
        }
        
        UIButton * button=[UIButton buttonWithType:UIButtonTypeCustom];
        button.frame=CGRectMake(cell.contentView.frame.origin.x, cell.contentView.frame.origin.y-1, cell.contentView.frame.size.width, cell.contentView.frame.size.height);
        button.tag=indexPath.row+100;
        [button addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
        [cell.contentView addSubview:button];
        UIView * line_view1 =[[UIView alloc]initWithFrame:CGRectMake(0, cell.contentView.frame.origin.y-button.frame.size.height, ROW_WIDTH, 1)];
        line_view1.backgroundColor=[UIColor whiteColor];
       // [cell.contentView addSubview:line_view1];
    }
    return cell;
}
- (void)buttonClick:(UIButton*)sender
{
    if ([_deledate respondsToSelector:@selector(myAlertView:clickedButtonAtIndex:)]) {
        [_deledate myAlertView:self clickedButtonAtIndex:sender.tag];
    }
}
- (void)show{
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    [window addSubview:self];
    _contentView.transform = CGAffineTransformMakeScale(1.2,1.2);
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.3];
    _contentView.transform = CGAffineTransformMakeScale(1.0,1.0);
    [UIView commitAnimations];
}

@end
