//
//  AppDelegate.h
//  PhotoEffects
//
//  Created by Bennett Smith on 1/28/12.
//  Copyright (c) 2012 iDevelopSoftware, Inc. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Quartz/Quartz.h>

@interface AppDelegate : NSObject <NSApplicationDelegate>

@property (assign) IBOutlet NSWindow *window;
@property (assign) IBOutlet QCView *quartzComposerView;

- (IBAction)captureImage:(id)sender;

- (IBAction)showSelectedFilter:(id)sender;
@end
