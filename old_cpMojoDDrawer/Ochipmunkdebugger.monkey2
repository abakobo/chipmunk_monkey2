
#Import "<std>"
#Import "<mojo>"
#Import "<chipmunk>"

Using std..
Using mojo..
Using chipmunk..

Class ChipmunkDebugger

	Field options:=New cpSpaceDebugDrawOptions
	
	Field scale:=1.0
	Field viewpoint:=cpv(0,0)
	Field w:=640
	Field h:=480
	Field y_axis_direction:=1

	Method New()
		options.drawCircle=DrawCircle
		options.drawSegment=DrawSegment
		options.drawFatSegment=DrawFatSegment
		options.drawPolygon=DrawPolygon
		options.drawDot=DrawDot
		options.colorForShape=ColorForShape
		options.flags=CP_SPACE_DEBUG_DRAW_SHAPES '|CP_SPACE_DEBUG_DRAW_CONSTRAINTS|CP_SPACE_DEBUG_DRAW_COLLISION_POINTS
	End
	
	Method DebugDraw( canvas:Canvas,space:cpSpace )
	
		_canvas=canvas
	
		cpSpaceDebugDraw( space,options )
	End
	
	Protected
	
	Method DrawCircle( pos:cpVect,angle:cpFloat,radius:cpFloat,outlineColor:cpSpaceDebugColor,fillColor:cpSpaceDebugColor,data:cpDataPointer )
	
		_canvas.Color=New Color( fillColor.r,fillColor.g,fillColor.b,fillColor.a )
		
		_canvas.DrawCircle( pos.x,pos.y,radius )
	End
	
	Method DrawSegment( a:cpVect,b:cpVect,color:cpSpaceDebugColor,data:cpDataPointer )

		_canvas.Color=New Color( color.r,color.g,color.b,color.a )

		_canvas.LineWidth=1
				
		_canvas.DrawLine( a.x,a.y,b.x,b.y )
	End
	
	Method DrawFatSegment( a:cpVect,b:cpVect,radius:cpFloat,outlineColor:cpSpaceDebugColor,fillColor:cpSpaceDebugColor,data:cpDataPointer )

		_canvas.Color=New Color( fillColor.r,fillColor.g,fillColor.b,fillColor.a )

		_canvas.LineWidth=radius
		
		_canvas.DrawLine( a.x,a.y,b.x,b.y )
	End
	
	Method DrawPolygon( count:Int,verts:cpVect Ptr,radius:cpFloat,outlineColor:cpSpaceDebugColor,fillColor:cpSpaceDebugColor,data:cpDataPointer )
	
		Local vs:=New Float[count*2]
		For Local i:=0 Until count
			vs[i*2]=verts[i].x
			vs[i*2+1]=verts[i].y
		Next

		_canvas.Color=New Color( fillColor.r,fillColor.g,fillColor.b,fillColor.a )
		
		_canvas.DrawPolys( count,1,vs )
	End
	
	Method DrawDot( size:cpFloat,pos:cpVect,color:cpSpaceDebugColor,data:cpDataPointer )

		_canvas.Color=New Color( color.r,color.g,color.b,color.a )

		_canvas.PointSize=size
		
		_canvas.DrawPoint( pos.x,pos.y )
	End
	
	Method ColorForShape:cpSpaceDebugColor( shape:cpShape,data:cpDataPointer )
	
		Local color:=_colors[shape]
		If color.a Return color
		
		color.r=Rnd( 1 )
		color.g=Rnd( 1-color.r )
		color.b=Rnd( 1-color.r-color.g )
		color.a=1
		
		_colors[shape]=color
		Return color
	End
	
	Private
	
	Field _colors:=New Map<cpShape,cpSpaceDebugColor>

	Field _canvas:Canvas
	
End
