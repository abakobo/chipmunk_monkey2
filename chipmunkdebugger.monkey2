#Import "<std>"
#Import "<mojo>"
#Import "<chipmunk>"

Using std..
Using mojo..
Using chipmunk..


Class ChipmunkDebugger

	Method New()
		_options.drawCircle=DrawCircle
		_options.drawSegment=DrawSegment
		_options.drawFatSegment=DrawFatSegment
		_options.drawPolygon=DrawPolygon
		_options.drawDot=DrawDot
		_options.colorForShape=ColorForShape
		_options.flags=CP_SPACE_DEBUG_DRAW_SHAPES|CP_SPACE_DEBUG_DRAW_CONSTRAINTS|CP_SPACE_DEBUG_DRAW_COLLISION_POINTS
		
		_options.shapeOutlineColor=RGBAColor(200.0/255.0, 210.0/255.0, 230.0/255.0, 1.0)
		_options.constraintColor=RGBAColor(0.0, 0.75, 0.0, 1.0)
		_options.collisionPointColor=RGBAColor(1.0, 0.0, 0.0, 1.0)
	End
	
	Method DebugDraw( canvas:Canvas,space:cpSpace )
	
		_canvas=canvas
	
		cpSpaceDebugDraw( space,_options )
	End
	
	Protected
	
	Method DrawCircle( pos:cpVect,angle:cpFloat,radius:cpFloat,outlineColor:cpSpaceDebugColor,fillColor:cpSpaceDebugColor,data:cpDataPointer )
	
		_canvas.Color=New Color( outlineColor.r,outlineColor.g,outlineColor.b,outlineColor.a )
		
		_canvas.DrawCircle( pos.x,pos.y,radius )
	
		_canvas.Color=New Color( fillColor.r,fillColor.g,fillColor.b,fillColor.a )
		
		_canvas.DrawCircle( pos.x,pos.y,radius*0.75 )
		
		_canvas.Color=Color.Black
		
		_canvas.LineWidth=1
		
		_canvas.DrawLine( pos.x,pos.y,pos.x+Cos( angle )*radius,pos.y+Sin( angle )*radius )
	End
	
	Method DrawSegment( a:cpVect,b:cpVect,color:cpSpaceDebugColor,data:cpDataPointer=Null )

		_canvas.Color=New Color( color.r,color.g,color.b,color.a )

		_canvas.LineWidth=1
				
		_canvas.DrawLine( a.x,a.y,b.x,b.y )
	End
	
	Method DrawFatSegment( a:cpVect,b:cpVect,radius:cpFloat,outlineColor:cpSpaceDebugColor,fillColor:cpSpaceDebugColor,data:cpDataPointer )
		
		_canvas.BlendMode=BlendMode.Opaque
		
		DrawFatSegmentMono( a,b,radius,outlineColor)
		DrawFatSegmentMono( a,b,radius*0.65,fillColor)

	End
	
	Method DrawFatSegmentMono( a:cpVect,b:cpVect,radius:cpFloat,fillColor:cpSpaceDebugColor )

		_canvas.Color=New Color( fillColor.r,fillColor.g,fillColor.b,fillColor.a )

		_canvas.LineWidth=radius*2
		
		_canvas.DrawLine( a.x,a.y,b.x,b.y )
		
		_canvas.DrawCircle( a.x,a.y,radius )
		
		_canvas.DrawCircle( b.x,b.y,radius )
	End
	
	Method DrawPolygon( count:Int,verts:cpVect Ptr,radius:cpFloat,outlineColor:cpSpaceDebugColor,fillColor:cpSpaceDebugColor,data:cpDataPointer )

		
		_canvas.BlendMode=BlendMode.Opaque
		
		For Local i:=1 Until count
			DrawFatSegmentMono( verts[i-1],verts[i],radius,outlineColor)
		Next
		DrawFatSegmentMono( verts[0],verts[count-1],radius,outlineColor)
		

		Local vs:=New Float[count*2]
		For Local i:=0 Until count
			vs[i*2]=verts[i].x
			vs[i*2+1]=verts[i].y
		Next
		
		_canvas.Color=New Color( fillColor.r,fillColor.g,fillColor.b,fillColor.a )
		_canvas.DrawPolys( count,1,vs )
		
		For Local i:=1 Until count
			DrawSegment( verts[i-1],verts[i],outlineColor)
		Next
		DrawSegment( verts[0],verts[count-1],outlineColor)
		
	End
	
	Method DrawDot( size:cpFloat,pos:cpVect,color:cpSpaceDebugColor,data:cpDataPointer )

		_canvas.Color=New Color( color.r,color.g,color.b,color.a )

		_canvas.PointSize=size
		
		_canvas.DrawPoint( pos.x,pos.y )
		
	End
	
	Method ColorForShape:cpSpaceDebugColor( shape:cpShape,data:cpDataPointer )
		
		If cpShapeGetSensor(shape)
			return LAColor(1.0, 0.1)
		Else
		
			Local body:=cpShapeGetBody(shape)
		
			If cpBodyIsSleeping(body)
				return LAColor(0.2, 1.0)
			else
				Local color:=_colors[shape]
				If color.a Return color
			
				color.r=Rnd( 1 )
				color.g=Rnd( 1-color.r )
				color.b=Rnd( 1-color.r-color.g )
				color.a=1
			
				_colors[shape]=color
				Return color
			Endif
			
		Endif
		
	End
	
	Private
	
	Field _options:=New cpSpaceDebugDrawOptions
	
	Field _colors:=New Map<cpShape,cpSpaceDebugColor>

	Field _canvas:Canvas
	
End

Function RGBAColor:cpSpaceDebugColor (r:float, g:float, b:float, a:float)
Local color:cpSpaceDebugColor
	 color.r=r
	 color.g=g
	 color.b=b
	 color.a=a
	return color 
End

Function LAColor:cpSpaceDebugColor (l:float , a:float )
	Local color:cpSpaceDebugColor
	color.r=l
	color.g=l
	color.b=l
	color.a=a
	return color
End