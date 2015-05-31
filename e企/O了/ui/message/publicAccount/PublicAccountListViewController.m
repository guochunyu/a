//
//  PublicAccountListViewController.m
//  e企
//
//  Created by roya-7 on 14/11/27.
//  Copyright (c) 2014年 QYB. All rights reserved.
//

#import "PublicAccountListViewController.h"
#import "MessageCell.h"

@interface PublicAccountListViewController (){
    NSMutableDictionary *cellDict;///<存放cell
    NSMutableArray *publicArray;
    AppDelegate *app;
}
@end

@implementation PublicAccountListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title=@"公众号";
    self.isLoadTable=YES;
    // Do any additional setup after loading the view.
//    app=[ConstantObject app];
//    app.showUnreadDelegate = self;
    cellDict=[[NSMutableDictionary alloc] init];
    publicArray=[[NSMutableArray alloc] init];
//
//    publicArray=
    
}
#pragma mark -
#pragma mark 接收到信息的回调

-(void)loadBaseData{
    [publicArray removeAllObjects];
    
    [cellDict removeAllObjects];
    
    for (ChatListModel *clm in [[SqliteDataDao sharedInstanse] queryChatListDataWithToUserId]){
        if (clm.chatType==2) {
            [publicArray addObjectsFromArray:clm.publicModelArray];
        }
    }
    [self.myTable reloadData];
}
-(void)viewWillAppear:(BOOL)animated{
    [self loadBaseData];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 表格数据源
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 64;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return publicArray.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSString *CellIdentifier = @"Cell";
    
    ChatListModel * message = publicArray[indexPath.row];
    
    NSString *cellDict_key=[NSString stringWithFormat:@"message_chat_cell_%@",message.toUserId];
    MessageCell *cell=[cellDict objectForKey:cellDict_key];
    if (!cell) {
        cell = [[MessageCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.cell_row=indexPath.row;
        message.publicModelArray=nil;
        cell.message=message;
        
        [cell addImageToHeadImage];
        
        if (cell.message.unReadCount<0) {
            cell.barB.remindNum=[message.unReadPublic integerValue];
        }else{
            cell.barB.remindNum=message.unReadCount;
        }
        
        cell.nameLabel.text=message.publicModel.name;
        
        switch (message.lastMessageType) {
            case 0:
            {
                [cell.detailLabel setEmojiText:message.lastMessage];
                break;
            }
            case 1:
            {
                
                cell.detailLabel.text =@"[图片]";
                break;
            }
            case 3:
            {
                NSError *error=nil;
                NSXMLElement *x_parse=[[NSXMLElement alloc] initWithXMLString:message.lastMessage error:&error];
                
                if (error) {
                    DDLogInfo(@"解析出错,error:%@",error);
                }else{
                    NSArray *articleArray=[[x_parse elementForName:@"article"] elementsForName:@"mediaarticle"];
                    NSXMLElement *dan_x=articleArray[0];
                    NSString *title = [[dan_x elementForName:@"title"] stringValue];
                    
                    if(![title length])
                    {
                        cell.detailLabel.text=[NSString stringWithFormat:@"%@",@""];
                        
                    }else
                    {
                        cell.detailLabel.text=[NSString stringWithFormat:@"%@",title];
                    }
                    
                }
                
                break;
            }
            case 2:
            {
                cell.detailLabel.text =@"[声音]";
                break;
            }
            
            case 4:{
                cell.detailLabel.text=@"[视频]";
                break;
            }
            default:
                break;
        }

        
        [cellDict setObject:cell forKey:cellDict_key];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    ChatListModel *clm=[publicArray objectAtIndex:indexPath.row];
    
    MessageChatViewController *detailViewController = [[MessageChatViewController alloc] init];
    detailViewController.hidesBottomBarWhenPushed=YES;
    detailViewController.chatType=2;
    detailViewController.publicModel=clm.publicModel;
    detailViewController.isNoToRootViewWhenBack=YES;
    //更新已读状态
    [[SqliteDataDao sharedInstanse] updateReadStateWithToUserId:clm.toUserId];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"haveSendMessage" object:nil];
    
    [self.navigationController pushViewController:detailViewController animated:YES];
}

-(void)reloadTabel{
//    self.messagesArray=array;
//    [cellDict removeAllObjects];
//    [self.myTable reloadData];
    [self loadBaseData];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
