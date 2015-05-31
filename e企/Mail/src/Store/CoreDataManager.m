//
//  CoreDataManager.m
//  EnterpriseMail
//
//  Created by 陆广庆 on 14/12/10.
//  Copyright (c) 2014年 陆广庆. All rights reserved.
//

#import "CoreDataManager.h"

static NSString * const kStoreFileName = @"maildb7.sqlite";


@interface CoreDataManager ()

@property (nonatomic) NSManagedObjectContext *masterContext;
//@property (nonatomic) NSManagedObjectContext *mainContext;
@property (nonatomic) NSManagedObjectModel *managedObjectModel;
@property (nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic) NSString *gid;
@property (nonatomic) NSString *uid;

@end

@implementation CoreDataManager

+ (CoreDataManager *)sharedInstance
{
    static CoreDataManager *sharedManager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [CoreDataManager new];
    });
    NSDictionary * dic=[[NSUserDefaults standardUserDefaults]objectForKey:MyUserInfo];
    NSString * uid=[dic[@"data"] isKindOfClass:[NSDictionary class]]?(dic[@"data"][@"uid"]):@"";
    NSString * gid=[[NSUserDefaults standardUserDefaults]objectForKey:myGID];
    if (![uid isEqualToString:sharedManager.uid] || ![gid isEqualToString:sharedManager.gid]) {
        sharedManager = [sharedManager init];
    }
    return sharedManager;
}

- (instancetype)init
{
    self = [super init];
//    if (self) {
        _managedObjectModel = [NSManagedObjectModel mergedModelFromBundles:nil];
        
        _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:self.managedObjectModel];
        NSURL *applicationDocumentsDirectory = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
        
        NSDictionary * dic=[[NSUserDefaults standardUserDefaults]objectForKey:MyUserInfo];
        NSString * uid=[dic[@"data"] isKindOfClass:[NSDictionary class]]?(dic[@"data"][@"uid"]):@"";
        NSString * gid=[[NSUserDefaults standardUserDefaults]objectForKey:myGID];
        self.gid = gid;
        self.uid = uid;
        NSURL *storeURL = [applicationDocumentsDirectory URLByAppendingPathComponent:[NSString stringWithFormat:@"%@_%@_%@",gid,uid,kStoreFileName]];
        
        NSError *error = NULL;
        NSDictionary *options = @{NSMigratePersistentStoresAutomaticallyOption : @(YES),
                                  NSInferMappingModelAutomaticallyOption : @(YES)};
//        [_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType
//                                                  configuration:nil
//                                                            URL:storeURL
//                                                        options:options
//                                                          error:&error];
        if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:options error:&error]) {
            //[[NSFileManager defaultManager]removeItemAtURL:storeURL error:nil];
            
        }

        
//        _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
//        _managedObjectContext.persistentStoreCoordinator = _persistentStoreCoordinator;
        
        _masterContext = [self setupContextWithConcurrencyType:NSPrivateQueueConcurrencyType];
        _masterContext.persistentStoreCoordinator = _persistentStoreCoordinator;
//        _mainContext = [self setupContextWithConcurrencyType:NSMainQueueConcurrencyType];
//        _mainContext.parentContext = _masterContext;
//    }
    return self;
}

- (NSManagedObjectContext *)setupContextWithConcurrencyType:(NSManagedObjectContextConcurrencyType)type
{
    NSManagedObjectContext *context = [[NSManagedObjectContext alloc] initWithConcurrencyType:type];
    return context;
}

- (NSManagedObject *)createManagedObject:(NSString *)entityName
{
    NSManagedObject *obj = [NSEntityDescription insertNewObjectForEntityForName:entityName inManagedObjectContext:_masterContext];
    return obj;
}

- (void)deleteManagedObject:(NSManagedObject *)obj
{
    [_masterContext deleteObject:obj];
}

- (void)save
{
    [_masterContext performBlockAndWait:^{
        [_masterContext save:NULL];
//        [_mainContext performBlock:^{
//            [_mainContext save:NULL];
//        }];
    }];
}

- (NSArray *)fetchAll:(NSString *)entityName
{
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:entityName];
    NSError *error = nil;
    NSArray *list = [_masterContext executeFetchRequest:request error:&error];
    return list;
}

- (NSArray *)fetch:(NSString *)entityName
                 condition:(NSString *)condition
                    filter:(NSArray *)filters
                   sortKey:(NSString *)sortKey
                 ascending:(BOOL)ascending
               fetchOffset:(NSInteger)fetchOffset
                fetchLimit:(NSInteger)fetchLimit
{
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:entityName];
    if (condition != nil) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:condition];
        [request setPredicate:predicate];
    }
    if (sortKey != nil) {
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:sortKey ascending:ascending];
        [request setSortDescriptors:@[sortDescriptor]];

    }
    if (fetchOffset >= 0) {
        [request setFetchOffset:fetchOffset];
    }
    if (fetchLimit >= 0) {
        [request setFetchLimit:fetchLimit];
    }
    NSError *error = nil;
    NSArray *result = [_masterContext executeFetchRequest:request error:&error];
    if (filters != nil) {
        for (NSString *filter in filters) {
            NSPredicate *p = [NSPredicate predicateWithFormat:filter];
            result = [result filteredArrayUsingPredicate:p];
        }
    }
    return result;
}

@end































