//
//  NSImage+JPegHelpers.h
//  PhotoEffects
//
//  Created by Bennett Smith on 1/28/12.
//  Copyright (c) 2012 iDevelopSoftware, Inc. All rights reserved.
//

#import <AppKit/AppKit.h>

@interface NSImage (JPegHelpers)
- (void) saveAsJpegWithName:(NSString*) fileName;
@end
