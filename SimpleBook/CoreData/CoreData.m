//
//  CoreData.m
//  DemoCoreData
//
//  Created by Shawn Welch on 10/23/11.
//  Copyright (c) 2011 anythingsimple.com. All rights reserved.
//

#import "CoreData.h"

#define iCloudSyncIfAvailable YES
#define ManagedObjectModelFileName @"DreamBook"

//iCloud Parameters
#warning Must replace these values with your information if using iCloud
#define UBIQUITY_CONTAINER_IDENTIFIER @"[TEAM_ID].com.mycompany.myapp"
#define UBIQUITY_CONTENT_NAME_KEY @"com.mycompany.myapp.CoreData"

static CoreData *sharedModel = nil;

@implementation CoreData
@synthesize delegates = _delegates;
@synthesize managedObjectContext = __managedObjectContext;
@synthesize managedObjectModel = __managedObjectModel;
@synthesize persistentStoreCoordinator = __persistentStoreCoordinator;

//iCloud
@synthesize iCloudAvailable = _iCloudAvailable;

#pragma mark - Singleton Creation

+ (id)sharedModel:(id<CoreDataDelegate>)delegate{
	@synchronized(self){
		if(sharedModel == nil)
			sharedModel = [[self alloc] initWithDelegate:delegate];
		else {
			if(delegate)
				[sharedModel.delegates addObject:delegate];
		}
	}
	return sharedModel;
}
+ (id)allocWithZone:(NSZone *)zone{
  @synchronized(self) {
    if(sharedModel == nil)  {
      sharedModel = [super allocWithZone:zone];
      return sharedModel;
    }
  }
  return nil;
}
+ (void)addDelegate:(id<CoreDataDelegate>)delegate{
	[sharedModel.delegates addObject:delegate];
}
+ (void)removeDelegate:(id<CoreDataDelegate>)delegate{
	[sharedModel.delegates removeObjectIdenticalTo:delegate];
}
- (id)initWithDelegate:(id<CoreDataDelegate>)newDelegate{
  self = [super init];
	if(self){
    
		_delegates = [[NSMutableArray alloc] init];
		if(newDelegate)
			[_delegates addObject:newDelegate];
		
    //Test for iCloud availability
    if(iCloudSyncIfAvailable){
      [[NSBundle mainBundle] bundleIdentifier];
      NSFileManager *fileManager = [NSFileManager defaultManager];
      NSURL *contentURL = [fileManager URLForUbiquityContainerIdentifier:UBIQUITY_CONTAINER_IDENTIFIER];
      if(contentURL)
        self.iCloudAvailable = YES;
      else
        self.iCloudAvailable = NO;
    }
    
    
    __managedObjectContext = [self managedObjectContext];
		
	}
	return self;
}

#pragma mark - Model Accessors




#pragma mark - Managed Object Context

- (BOOL)saveContext{
  NSError *error = nil;
  NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
  if (managedObjectContext != nil){
    if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]){
      /*
       Replace this implementation with code to handle the error appropriately.
       
       abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
       */
      NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
      return NO;
    }
  }
  else{
    NSLog(@"Managed Object Context is nil");
    return NO;
  }
  NSLog(@"Context Saved, iCloud should sync if enabled");
  
  return YES;
}

#pragma mark - Undo/Redo Operations


- (void)undo{
  [__managedObjectContext undo];
  
}

- (void)redo{
  [__managedObjectContext redo];
}

- (void)rollback{
  [__managedObjectContext rollback];
}

- (void)reset{
  [__managedObjectContext reset];
}

#pragma mark - Core Data stack

/**
 Returns the managed object context for the application.
 If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
 */
- (NSManagedObjectContext *)managedObjectContext{
  if (__managedObjectContext != nil){
    return __managedObjectContext;
  }
  
  NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
  if (coordinator != nil){
    
    NSManagedObjectContext *moc = [[NSManagedObjectContext alloc]
                                   initWithConcurrencyType:NSMainQueueConcurrencyType];
    
    [moc performBlockAndWait:^(void){
      // Set up an undo manager, not included by default
      NSUndoManager *undoManager = [[NSUndoManager alloc] init];
      [undoManager setGroupsByEvent:NO];
      [moc setUndoManager:undoManager];
      
      
      // Set persistent store
      [moc setPersistentStoreCoordinator:coordinator];
      
      //icloud
      if(iCloudSyncIfAvailable){
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(persistentStoreDidChange:)
                                                     name:NSPersistentStoreDidImportUbiquitousContentChangesNotification
                                                   object:coordinator];
      }
    }];
    
    
    __managedObjectContext = moc;
  }
  return __managedObjectContext;
}

/**
 Returns the managed object model for the application.
 If the model doesn't already exist, it is created from the application's model.
 */
- (NSManagedObjectModel *)managedObjectModel{
  if (__managedObjectModel != nil)
  {
    return __managedObjectModel;
  }
  
  NSURL *modelURL = [[NSBundle mainBundle] URLForResource:ManagedObjectModelFileName withExtension:@"momd"];
  __managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
  return __managedObjectModel;
}

/**
 Returns the persistent store coordinator for the application.
 If the coordinator doesn't already exist, it is created and the application's store added to it.
 */
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator{
  if (__persistentStoreCoordinator != nil){
    return __persistentStoreCoordinator;
  }
  
  // Set up persistent Store Coordinator
  __persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
  
  // Set up SQLite db and options dictionary
  NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:[NSString stringWithFormat:@"%@.sqlite",ManagedObjectModelFileName]];
  NSDictionary *options = nil;
  
  // If we want to use iCloud, set up
  if(iCloudSyncIfAvailable && _iCloudAvailable){
    [[NSBundle mainBundle] bundleIdentifier];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *contentURL = [fileManager URLForUbiquityContainerIdentifier:UBIQUITY_CONTAINER_IDENTIFIER];
    
    options = [NSDictionary dictionaryWithObjectsAndKeys:
               UBIQUITY_CONTENT_NAME_KEY,
               NSPersistentStoreUbiquitousContentNameKey,
               contentURL,
               NSPersistentStoreUbiquitousContentURLKey,
               nil];
    
  }
  else if(!_iCloudAvailable){
    NSLog(@"Attempted to set up iCloud Core Data Stack, but iCloud is unvailable");
  }
  
  // Add the persistent store to the persistent store coordinator
  NSError *error = nil;
  if (![__persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType
                                                  configuration:nil
                                                            URL:storeURL
                                                        options:options
                                                          error:&error]){
    // Handle the error
    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
    abort();
  }
  
  
  
  return __persistentStoreCoordinator;
}

#pragma mark - Application's Documents directory

/**
 Returns the URL to the application's Documents directory.
 */
- (NSURL *)applicationDocumentsDirectory{
  return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

#pragma mark - iCloud Functionality

- (void)persistentStoreDidChange:(NSNotification*)notification{
  NSLog(@"Change Detected!");
  [__managedObjectContext performBlockAndWait:^(void){
    [__managedObjectContext mergeChangesFromContextDidSaveNotification:notification];
    
    for(id<CoreDataDelegate>delegate in _delegates){
      if([delegate respondsToSelector:@selector(persistentStoreDidChange)])
        [delegate persistentStoreDidChange];
    }
  }];
}

@end
