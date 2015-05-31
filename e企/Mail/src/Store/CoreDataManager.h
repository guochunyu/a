//
//  CoreDataManager.h
//  EnterpriseMail
//
//  Created by 陆广庆 on 14/12/10.
//  Copyright (c) 2014年 陆广庆. All rights reserved.
//

@import Foundation;
@import CoreData;

@interface CoreDataManager : NSObject

+ (CoreDataManager *)sharedInstance;

- (NSManagedObject *)createManagedObject:(NSString *)entityName;
- (void)deleteManagedObject:(NSManagedObject *)obj;
- (void)save;
- (NSArray *)fetchAll:(NSString *)entityName;

- (NSArray *)fetch:(NSString *)entityName
         condition:(NSString *)condition
            filter:(NSArray *)filters
           sortKey:(NSString *)sortKey
         ascending:(BOOL)ascending
       fetchOffset:(NSInteger)fetchOffset
        fetchLimit:(NSInteger)fetchLimit;


@end
