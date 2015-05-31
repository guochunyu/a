//
//  UserModel.h
//  ChatDemo
//


//

#import <Foundation/Foundation.h>

@interface UserModel : NSObject {
    NSString *_jid;
    NSString *_pasword;
    NSString *_status;
}
@property (nonatomic, copy) NSString *jid;
@property (nonatomic, copy) NSString *password;
@property (nonatomic, copy) NSString *status;

@property(nonatomic,copy)NSString *jidStr;///登录名,不包括@

- (BOOL) isOnline;

@end
