#Import "<std>"
#Import "<mojo>"
#Import "<chipmunk>"

Using std..
Using mojo..
Using chipmunk..


Class ChipmunkDebugger

	Field options:=New cpSpaceDebugDrawOptions

	Method New()
	
		options.drawCircle=DrawCircleF
		options.drawSegment=DrawSegmentF
		options.drawFatSegment=DrawFatSegmentF
		options.drawPolygon=DrawPolygonF
		options.drawDot=DrawDotF
		options.colorForShape=ColorForShapeF
		options.flags=CP_SPACE_DEBUG_DRAW_SHAPES'|CP_SPACE_DEBUG_DRAW_CONSTRAINTS|CP_SPACE_DEBUG_DRAW_COLLISION_POINTS
		
		options.shapeOutlineColor=RGBAColor(200.0/255.0, 210.0/255.0, 230.0/255.0, 1.0)
		options.constraintColor=RGBAColor(0.0, 0.75, 0.0, 1.0)
		options.collisionPointColor=RGBAColor(1.0, 0.0, 0.0, 1.0)
		
	End
	
	Method DebugDraw( canvas:Canvas,space:cpSpace )
	
		_canvas=canvas
	
		cpSpaceDebugDraw( space,options )
		
	End
	
	Method FastDraw()
		options.drawCircle=DrawCircleF
		options.drawSegment=DrawSegmentF
		options.drawFatSegment=DrawFatSegmentF
		options.drawPolygon=DrawPolygonF
		options.drawDot=DrawDotF
		options.colorForShape=ColorForShapeF
		options.flags=CP_SPACE_DEBUG_DRAW_SHAPES
	End
	
	Method CompleteDraw()
		options.drawCircle=DrawCircle
		options.drawSegment=DrawSegment
		options.drawFatSegment=DrawFatSegment
		options.drawPolygon=DrawPolygon
		options.drawDot=DrawDot
		options.colorForShape=ColorForShape
		options.flags=CP_SPACE_DEBUG_DRAW_SHAPES |CP_SPACE_DEBUG_DRAW_CONSTRAINTS|CP_SPACE_DEBUG_DRAW_COLLISION_POINTS
	End
	
	Protected
	
	Method DrawCircle( pos:cpVect,angle:cpFloat,radius:cpFloat,outlineColor:cpSpaceDebugColor,fillColor:cpSpaceDebugColor,data:cpDataPointer )
	
		_canvas.Color=New Color( outlineColor.r,outlineColor.g,outlineColor.b,outlineColor.a )
		
		_canvas.DrawCircle( pos.x,pos.y,radius )
	
		_canvas.Color=New Color( fillColor.r,fillColor.g,fillColor.b,fillColor.a )
		
		_canvas.DrawCircle( pos.x,pos.y,radius*0.75 )
		
		_canvas.Color=Color.Black
		
		_canvas.LineWidth=0
		
		_canvas.DrawLine( pos.x,pos.y,pos.x+Cos( angle )*radius,pos.y+Sin( angle )*radius )
	End
	
	Method DrawSegment( a:cpVect,b:cpVect,color:cpSpaceDebugColor,data:cpDataPointer=Null )

		_canvas.Color=New Color( color.r,color.g,color.b,color.a )

		_canvas.LineWidth=0
				
		_canvas.DrawLine( a.x,a.y,b.x,b.y )
	End
	
	Method DrawFatSegment( a:cpVect,b:cpVect,radius:cpFloat,outlineColor:cpSpaceDebugColor,fillColor:cpSpaceDebugColor,data:cpDataPointer )
		
		_canvas.BlendMode=BlendMode.Opaque
		
		_canvas.LineWidth=radius*2
		
		_canvas.Color=New Color( outlineColor.r,outlineColor.g,outlineColor.b,outlineColor.a )
		
		_canvas.DrawLine( a.x,a.y,b.x,b.y )
		
		_canvas.DrawCircle( a.x,a.y,radius )
		
		_canvas.DrawCircle( b.x,b.y,radius )
		
		_canvas.Color=New Color( fillColor.r,fillColor.g,fillColor.b,fillColor.a )
		
		_canvas.LineWidth=radius*2*0.65
		
		_canvas.DrawLine( a.x,a.y,b.x,b.y )
		
		_canvas.DrawCircle( a.x,a.y,radius*0.65 )
		
		_canvas.DrawCircle( b.x,b.y,radius*0.65 )

	End
	
	
	Method DrawPolygon( count:Int,verts:cpVect Ptr,radius:cpFloat,outlineColor:cpSpaceDebugColor,fillColor:cpSpaceDebugColor,data:cpDataPointer )

		
		_canvas.BlendMode=BlendMode.Opaque
		
		
		Local vs:=New Float[count*2]
		For Local i:=0 Until count
			vs[i*2]=verts[i].x
			vs[i*2+1]=verts[i].y
		Next
		
		_canvas.Color=New Color( fillColor.r,fillColor.g,fillColor.b,fillColor.a )
		_canvas.DrawPolys( count,1,vs )
		
		
		_canvas.Color=New Color( outlineColor.r,outlineColor.g,outlineColor.b,outlineColor.a )
		If radius=0	
		
			For Local i:=1 Until count
			
				DrawSegment( verts[i-1],verts[i],outlineColor)
				
			Next
			
			DrawSegment( verts[0],verts[count-1],outlineColor)
			
		Else
		
				_canvas.LineWidth=radius*2		
		
			For Local i:=1 Until count
			
				_canvas.DrawLine( verts[i-1].x,verts[i-1].y,verts[i].x,verts[i].y )
			
				_canvas.DrawCircle( verts[i-1].x,verts[i-1].y,radius )
				
			Next
			
			_canvas.DrawLine( verts[count-1].x,verts[count-1].y,verts[0].x,verts[0].y )
			
			_canvas.DrawCircle( verts[count-1].x,verts[count-1].y,radius )
			
		Endif


		
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
				Return LAColor(0.2, 1.0)
			Else
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
	
	Method DrawCircleF( pos:cpVect,angle:cpFloat,radius:cpFloat,outlineColor:cpSpaceDebugColor,fillColor:cpSpaceDebugColor,data:cpDataPointer )
	
		_canvas.Color=New Color( fillColor.r,fillColor.g,fillColor.b,fillColor.a )
		
		_canvas.DrawCircle( pos.x,pos.y,radius )
		
		_canvas.Color=Color.Black
		
		_canvas.LineWidth=0
			
		_canvas.DrawLine( pos.x,pos.y,pos.x+Cos( angle )*radius,pos.y+Sin( angle )*radius )
	End
	
	Method DrawSegmentF( a:cpVect,b:cpVect,color:cpSpaceDebugColor,data:cpDataPointer )

		_canvas.Color=New Color( color.r,color.g,color.b,color.a )

		_canvas.LineWidth=0
				
		_canvas.DrawLine( a.x,a.y,b.x,b.y )
	End
	
	Method DrawFatSegmentF( a:cpVect,b:cpVect,radius:cpFloat,outlineColor:cpSpaceDebugColor,fillColor:cpSpaceDebugColor,data:cpDataPointer )

		_canvas.Color=New Color( fillColor.r,fillColor.g,fillColor.b,fillColor.a )

		_canvas.LineWidth=radius*2
		
		_canvas.BlendMode=BlendMode.Opaque
		
		_canvas.DrawLine( a.x,a.y,b.x,b.y )
		
		_canvas.DrawCircle( a.x,a.y,radius )
		
		_canvas.DrawCircle( b.x,b.y,radius )
	End
	
	Method DrawPolygonF( count:Int,verts:cpVect Ptr,radius:cpFloat,outlineColor:cpSpaceDebugColor,fillColor:cpSpaceDebugColor,data:cpDataPointer )

			_canvas.BlendMode=BlendMode.Opaque	
			_canvas.Color=New Color( fillColor.r,fillColor.g,fillColor.b,fillColor.a )
			
			'Local rad:=radius*2
			
			_canvas.LineWidth=radius*2
		
			For Local i:=1 Until count
			
				_canvas.DrawLine( verts[i-1].x,verts[i-1].y,verts[i].x,verts[i].y )
			
				_canvas.DrawCircle( verts[i-1].x,verts[i-1].y,radius )
				
			Next
			
			_canvas.DrawLine( verts[count-1].x,verts[count-1].y,verts[0].x,verts[0].y )
			
			_canvas.DrawCircle( verts[count-1].x,verts[count-1].y,radius )

		
	End
	
	Method DrawDotF( size:cpFloat,pos:cpVect,color:cpSpaceDebugColor,data:cpDataPointer )

		_canvas.Color=New Color( color.r,color.g,color.b,color.a )

		_canvas.PointSize=size
		
		_canvas.DrawPoint( pos.x,pos.y )
	End
	
	Method ColorForShapeF:cpSpaceDebugColor( shape:cpShape,data:cpDataPointer )
	
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

Class Canvas Extension

	Method SetCamera(centerpoint_x:Float,centerpoint_y:Float,zoom:Float=1.0,rotation:Float=0.0)

		Translate(Viewport.Width/2,Viewport.Height/2)
		Scale(zoom,zoom)
		Rotate(rotation)
		Translate(-centerpoint_x,-centerpoint_y)

	End
	
	Method SetCamera(centerpoint:Vec2f,zoom:Float=1.0,rotation:Float=0)

		Translate(Viewport.Width/2,Viewport.Height/2)
		Scale(zoom,zoom)
		Rotate(rotation)
		Translate(-centerpoint)

	End
	
End