//
//  ImageExporterPlugIn.m
//  ImageExporter
//
//  Created by Bennett Smith on 1/29/12.
//  Copyright (c) 2012 iDevelopSoftware, Inc. All rights reserved.
//

/* It's highly recommended to use CGL macros instead of changing the current context for plug-ins that perform OpenGL rendering */
#import <OpenGL/CGLMacro.h>

#import "ImageExporterPlugIn.h"

#define	kQCPlugIn_Name				@"Image Exporter"
#define	kQCPlugIn_Description		@"Writes the input image as a series of .png files to disk."

@implementation ImageExporterPlugIn

/* We need to declare the input / output properties as dynamic as Quartz Composer will handle their implementation */
@dynamic inputImage, inputPath, inputFilename;

+ (NSDictionary*) attributes
{
	/* Return the attributes of this plug-in */
	return [NSDictionary dictionaryWithObjectsAndKeys:kQCPlugIn_Name, QCPlugInAttributeNameKey, kQCPlugIn_Description, QCPlugInAttributeDescriptionKey, nil];
}

+ (NSDictionary*) attributesForPropertyPortWithKey:(NSString*)key
{
	/* Return the attributes for the plug-in property ports */
	if([key isEqualToString:@"inputImage"])
        return [NSDictionary dictionaryWithObjectsAndKeys:@"Image", QCPortAttributeNameKey, nil];
    
	if([key isEqualToString:@"inputPath"])
        return [NSDictionary dictionaryWithObjectsAndKeys:@"Destination Path", QCPortAttributeNameKey, @"~/Desktop", QCPortAttributeDefaultValueKey, nil];
	
    if ([key isEqualToString:@"inputFilename"])
        return [NSDictionary dictionaryWithObjectsAndKeys:@"Destination File Name", QCPortAttributeNameKey, @"sample.png", QCPortAttributeDefaultValueKey, nil];
    
	return nil;
}

+ (QCPlugInExecutionMode) executionMode
{
	/* This plug-in is a consumer (it renders to image files) */
	return kQCPlugInExecutionModeConsumer;
}

+ (QCPlugInTimeMode) timeMode
{
	/* This plug-in does not depend on the time (time parameter is completely ignored in the -execute:atTime:withArguments: method) */
	return kQCPlugInTimeModeNone;
}

@end

@implementation ImageExporterPlugIn (Execution)

- (BOOL) startExecution:(id<QCPlugInContext>)context
{
	/* Reset image file index */
	_index = 0;
	
	return YES;
}

- (BOOL) execute:(id<QCPlugInContext>)context atTime:(NSTimeInterval)time withArguments:(NSDictionary*)arguments
{
	id<QCPlugInInputImageSource>	qcImage = self.inputImage;
	NSString*						pixelFormat;
	CGColorSpaceRef					colorSpace;
	CGDataProviderRef				dataProvider;
	CGImageRef						cgImage;
	CGImageDestinationRef			imageDestination;
	NSURL*							fileURL;
	BOOL							success;
	
	/* Make sure we have a new image */
	if(![self didValueForInputKeyChange:@"inputImage"] || !qcImage || ![self.inputPath length])
        return YES;
	
	/* Figure out pixel format and colorspace to use */
	colorSpace = [qcImage imageColorSpace];
	
    if(CGColorSpaceGetModel(colorSpace) == kCGColorSpaceModelMonochrome)
        pixelFormat = QCPlugInPixelFormatI8;
	else if(CGColorSpaceGetModel(colorSpace) == kCGColorSpaceModelRGB)
#if __BIG_ENDIAN__
        pixelFormat = QCPlugInPixelFormatARGB8;
#else
    pixelFormat = QCPlugInPixelFormatBGRA8;
#endif
	else
        return NO;
	
	/* Get a buffer representation from the image in its native colorspace */
	if(![qcImage lockBufferRepresentationWithPixelFormat:pixelFormat colorSpace:colorSpace forBounds:[qcImage imageBounds]])
        return NO;
	
	/* Create CGImage from buffer */
	dataProvider = CGDataProviderCreateWithData(NULL, [qcImage bufferBaseAddress], [qcImage bufferPixelsHigh] * [qcImage bufferBytesPerRow], NULL);
	cgImage = CGImageCreate([qcImage bufferPixelsWide], [qcImage bufferPixelsHigh], 8, (pixelFormat == QCPlugInPixelFormatI8 ? 8 : 32), [qcImage bufferBytesPerRow], colorSpace, (pixelFormat == QCPlugInPixelFormatI8 ? 0 : kCGImageAlphaPremultipliedFirst | kCGBitmapByteOrder32Host), dataProvider, NULL, false, kCGRenderingIntentDefault);
	CGDataProviderRelease(dataProvider);
	if(cgImage == NULL) {
		[qcImage unlockBufferRepresentation];
		return NO;
	}
	
	/* Write CGImage to disk as PNG file */
	fileURL = [NSURL fileURLWithPath:[[self.inputPath stringByStandardizingPath] stringByAppendingPathComponent:self.inputFilename]];
	imageDestination = (fileURL ? CGImageDestinationCreateWithURL((CFURLRef)fileURL, kUTTypePNG, 1, NULL) : NULL);
	if(imageDestination == NULL) {
		CGImageRelease(cgImage);
		[qcImage unlockBufferRepresentation];
		return NO;
	}
	CGImageDestinationAddImage(imageDestination, cgImage, NULL);
	success = CGImageDestinationFinalize(imageDestination);
	CFRelease(imageDestination);
	
	/* Destroy CGImage */
	CGImageRelease(cgImage);
	
	/* Release buffer representation */
	[qcImage unlockBufferRepresentation];
	
	return success;
}

@end
