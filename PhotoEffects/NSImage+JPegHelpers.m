//
//  NSImage+JPegHelpers.m
//  PhotoEffects
//
//  Created by Bennett Smith on 1/28/12.
//  Copyright (c) 2012 iDevelopSoftware, Inc. All rights reserved.
//

#import "NSImage+JPegHelpers.h"

@implementation NSImage (JPegHelpers)

- (void) saveAsJpegWithName:(NSString*) fileName
{
    // Cache the reduced image
    NSData *imageData = [self TIFFRepresentation];
    NSBitmapImageRep *imageRep = [NSBitmapImageRep imageRepWithData:imageData];
    NSDictionary *imageProps = [NSDictionary dictionaryWithObject:[NSNumber numberWithFloat:1.0] forKey:NSImageCompressionFactor];
    imageData = [imageRep representationUsingType:NSJPEGFileType properties:imageProps];
    [imageData writeToFile:fileName atomically:YES];        
}

@end