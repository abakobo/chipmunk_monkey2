

#include <stdio.h>
#include <string.h>
#include <limits.h>
#include <stdarg.h>
#include "chipmunk/chipmunk_private.h"
#include "ChipmunkDebugDraw.h"

#ifndef CPMX2_COLORCALLBACK

static cpSpaceDebugColor
ColorForShape(cpShape *shape, cpDataPointer data)
{
	if(cpShapeGetSensor(shape)){
		return LAColor(1.0f, 0.1f);
	} else {
		cpBody *body = cpShapeGetBody(shape);
		
		if(cpBodyIsSleeping(body)){
			return LAColor(0.2f, 1.0f);
		} else if(body->sleeping.idleTime > shape->space->sleepTimeThreshold) {
			return LAColor(0.66f, 1.0f);
		} else {
			uint32_t val = (uint32_t)shape->hashid;
			
			// scramble the bits up using Robert Jenkins' 32 bit integer hash function
			val = (val+0x7ed55d16) + (val<<12);
			val = (val^0xc761c23c) ^ (val>>19);
			val = (val+0x165667b1) + (val<<5);
			val = (val+0xd3a2646c) ^ (val<<9);
			val = (val+0xfd7046c5) + (val<<3);
			val = (val^0xb55a4f09) ^ (val>>16);
			
			cpFloat r = (cpFloat)((val>>0) & 0xFF);
			cpFloat g = (cpFloat)((val>>8) & 0xFF);
			cpFloat b = (cpFloat)((val>>16) & 0xFF);
			
			cpFloat max = (cpFloat)cpfmax(cpfmax(r, g), b);
			cpFloat min = (cpFloat)cpfmin(cpfmin(r, g), b);
			cpFloat intensity = (cpBodyGetType(body) == CP_BODY_TYPE_STATIC ? 0.15f : 0.75f);
			
			// Saturate and scale the color
			if(min == max){
				return RGBAColor(intensity, 0.0f, 0.0f, 1.0f);
			} else {
				cpFloat coef = (cpFloat)intensity/(max - min);
				return RGBAColor(
					(r - min)*coef,
					(g - min)*coef,
					(b - min)*coef,
					1.0f
				);
			}
		}
	}
}

#endif