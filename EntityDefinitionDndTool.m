//
//  EntityDefinitionDragTool.m
//  TrenchBroom
//
//  Created by Kristian Duske on 18.07.11.
//  Copyright 2011 TU Berlin. All rights reserved.
//

#import "EntityDefinitionDndTool.h"
#import "EntityDefinition.h"
#import "MapWindowController.h"
#import "MapDocument.h"
#import "Entity.h"
#import "Camera.h"
#import "SelectionManager.h"
#import "PickingHitList.h"
#import "PickingHit.h"
#import "Face.h"
#import "Grid.h"
#import "Options.h"
#import "EntityDefinitionDndFeedbackFigure.h"
#import "Renderer.h"

@interface EntityDefinitionDndTool (private)

- (void)update:(id <NSDraggingInfo>)sender hits:(PickingHitList *)hits;

@end

@implementation EntityDefinitionDndTool (private)

- (void)update:(id <NSDraggingInfo>)sender hits:(PickingHitList *)hits {
    TVector3i posi;
    PickingHit* hit = [hits firstHitOfType:HT_FACE ignoreOccluders:YES];
    Grid* grid = [[windowController options] grid];

    if (hit != nil) {
        const TVector3f* hitPoint = [hit hitPoint];
        const TBoundingBox* bounds = [[entity entityDefinition] bounds];
        TVector3f size;
        sizeOfBounds(bounds, &size);
        
        id <Face> face = [hit object];
        TVector3f* faceNorm = [face norm];
        
        EAxis lc = largestComponentV3f(faceNorm);
        BOOL d;
        switch (lc) {
            case A_X:
                if (faceNorm->x > 0) {
                    posi.x = hitPoint->x - bounds->min.x;
                    posi.y = hitPoint->y - bounds->min.y - size.y / 2;
                    posi.z = hitPoint->z - bounds->min.z - size.z / 2;
                    d = YES;
                } else {
                    posi.x = hitPoint->x - size.x - bounds->min.x;
                    posi.y = hitPoint->y - bounds->min.y - size.y / 2;
                    posi.z = hitPoint->z - bounds->min.z - size.z / 2;
                    d = NO;
                }
                break;
            case A_Y:
                if (faceNorm->y > 0) {
                    posi.x = hitPoint->x - bounds->min.x - size.x / 2;
                    posi.y = hitPoint->y - bounds->min.y;
                    posi.z = hitPoint->z - bounds->min.z - size.z / 2;
                    d = YES;
                } else {
                    posi.x = hitPoint->x - bounds->min.x - size.x / 2;
                    posi.y = hitPoint->y - size.y - bounds->min.y;
                    posi.z = hitPoint->z - bounds->min.z - size.z / 2;
                    d = NO;
                }
                break;
            case A_Z:
                if (faceNorm->z > 0) {
                    posi.x = hitPoint->x - bounds->min.x - size.x / 2;
                    posi.y = hitPoint->y - bounds->min.y - size.y / 2;
                    posi.z = hitPoint->z - bounds->min.z;
                    d = YES;
                } else {
                    posi.x = hitPoint->x - bounds->min.x - size.x / 2;
                    posi.y = hitPoint->y - bounds->min.y - size.y / 2;
                    posi.z = hitPoint->z - size.z - bounds->min.z;
                    d = NO;
                }
                break;
        }
        [grid snapToGridV3i:&posi result:&posi];
        
        if (feedbackFigure == nil) {
            feedbackFigure = [[EntityDefinitionDndFeedbackFigure alloc] initWithEntityDefinition:[entity entityDefinition]];
            Renderer* renderer = [windowController renderer];
            [renderer addFeedbackFigure:feedbackFigure];
        }
        
        [feedbackFigure setAxis:lc direction:d];
        [feedbackFigure setOrigin:&posi];
    } else {
        Camera* camera = [windowController camera];
        NSPoint location = [sender draggingLocation];
        TVector3f posf = [camera unprojectX:location.x y:location.y depth:0.94f];
        roundV3f(&posf, &posi);
        [grid snapToGridV3i:&posi result:&posi];
        
        if (feedbackFigure != nil) {
            Renderer* renderer = [windowController renderer];
            [renderer removeFeedbackFigure:feedbackFigure];
            [feedbackFigure release];
            feedbackFigure = nil;
        }
    }
    
    MapDocument* map = [windowController document];
    [map setEntity:entity propertyKey:OriginKey value:[NSString stringWithFormat:@"%i %i %i", posi.x, posi.y, posi.z]];
    
}

@end

@implementation EntityDefinitionDndTool

- (id)initWithWindowController:(MapWindowController *)theWindowController {
    NSAssert(theWindowController != nil, @"window controller must not be nil");
    
    if ((self = [self init])) {
        windowController = theWindowController;
    }
    
    return self;
}

- (NSDragOperation)handleDraggingEntered:(id <NSDraggingInfo>)sender ray:(TRay *)ray hits:(PickingHitList *)hits {
    NSPasteboard* pasteboard = [sender draggingPasteboard];
    NSString* type = [pasteboard availableTypeFromArray:[NSArray arrayWithObject:EntityDefinitionType]];

    MapDocument* map = [windowController document];
    NSString* className = [[NSString alloc] initWithData:[pasteboard dataForType:type] encoding:NSUTF8StringEncoding];
    entity = [map createEntityWithClassname:className];
    
    SelectionManager* selectionManager = [windowController selectionManager];
    [selectionManager removeAll:YES];
    [selectionManager addEntity:entity record:YES];

    [self update:sender hits:hits];
    return NSDragOperationCopy;
}

- (NSDragOperation)handleDraggingUpdated:(id <NSDraggingInfo>)sender ray:(TRay *)ray hits:(PickingHitList *)hits {
    [self update:sender hits:hits];
    return NSDragOperationCopy;
}

- (void)handleDraggingEnded:(id <NSDraggingInfo>)sender ray:(TRay *)ray hits:(PickingHitList *)hits {
    if (feedbackFigure != nil) {
        Renderer* renderer = [windowController renderer];
        [renderer removeFeedbackFigure:feedbackFigure];
        [feedbackFigure release];
        feedbackFigure = nil;
    }
}

- (void)handleDraggingExited:(id <NSDraggingInfo>)sender ray:(TRay *)ray hits:(PickingHitList *)hits {
    if (feedbackFigure != nil) {
        Renderer* renderer = [windowController renderer];
        [renderer removeFeedbackFigure:feedbackFigure];
        [feedbackFigure release];
        feedbackFigure = nil;
    }
}

- (BOOL)prepareForDragOperation:(id <NSDraggingInfo>)sender ray:(TRay *)ray hits:(PickingHitList *)hits {
    return YES;
}

- (BOOL)performDragOperation:(id <NSDraggingInfo>)sender ray:(TRay *)ray hits:(PickingHitList *)hits {
    return YES;
}

- (void)concludeDragOperation:(id <NSDraggingInfo>)sender ray:(TRay *)ray hits:(PickingHitList *)hits {
    if (feedbackFigure != nil) {
        Renderer* renderer = [windowController renderer];
        [renderer removeFeedbackFigure:feedbackFigure];
        [feedbackFigure release];
        feedbackFigure = nil;
    }
}


@end
