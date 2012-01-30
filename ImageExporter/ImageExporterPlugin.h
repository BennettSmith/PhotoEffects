//
//  ImageExporterPlugin.h
//  ImageExporter
//
//  Created by Bennett Smith on 1/29/12.
//  Copyright (c) 2012 iDevelopSoftware, Inc. All rights reserved.
//  
//  Modified from the ImageExporterPlugIn supplied by Apple as a developer sample.

#import <Quartz/Quartz.h>

@interface ImageExporterPlugIn : QCPlugIn
{
	NSUInteger					_index;
}

/* Declare a property input port of type "Image" and with the key "inputImage" */
@property(assign) id<QCPlugInInputImageSource> inputImage;

/* Declare a property input port of type "String" and with the key "inputPath" */
@property(assign) NSString* inputPath;

/* Declare a property input port of type "String" and with the key "inputFilename" */
@property(assign) NSString* inputFilename;

@end
