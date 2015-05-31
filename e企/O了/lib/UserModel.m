//
//  UserModel.m
//  ChatDemo
//

//

#import "UserModel.h"

@implementation UserModel
@synthesize jid = _jid, password  = _pasword, status= _status;

- (BOOL) isOnline {
    if ([self.status isEqualToString:@"unavailable"]) {
        return NO;
    }
    return YES;
}

@end
