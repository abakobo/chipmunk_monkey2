Namespace chipmunk

#Import "<std>"
#Import "<mojo>"
#Import "<chipmunk>"

Using std..
Using mojo..

Public


Global cp_GLOBAL_canvas:Canvas
Global CP_DEBUG_DRAWER:=New cpDebugDrawer()

Class cpDebugDrawer

	Field scale:=1.0
	Field viewpoint:=cpv(0,0)
	Field w:=640
	Field h:=480
	Field y_axis_direction:=1 'to invert y axis for screen draw (supposed to be 1 or -1 only)
	
	Field options:cpSpaceDebugDrawOptions
	'Field img:=New Image (64,64,TextureFlags.Dynamic) 'generates memory acces violation??!!
	'Field canvator:Canvas 'this
	
	Method New()
	
		'img=
		'canvator= New Canvas(img)

		options.drawCircle=cp_mojo_DDrawCircle
		options.drawDot=cp_mojo_DDrawDot 	
		options.drawFatSegment=cp_mojo_DDrawFatSegment 	
		options.drawPolygon=cp_mojo_DDrawPolygon 	
		options.drawSegment=cp_mojo_DDrawSegment
		
		options.colorForShape=DebugColorForShape
		options.flags=(CP_SPACE_DEBUG_DRAW_SHAPES | CP_SPACE_DEBUG_DRAW_CONSTRAINTS | CP_SPACE_DEBUG_DRAW_COLLISION_POINTS)
		options.shapeOutlineColor=ColorTocpSpaceDebugColor(New Color(200.0/255.0, 210.0/255.0, 230.0/255.0, 1.0))
		options.constraintColor=ColorTocpSpaceDebugColor(New Color(0.0, 0.75, 0.0, 1.0))
		options.collisionPointColor=ColorTocpSpaceDebugColor(New Color(1.0, 0.0, 0.0, 1.0))
		
	End
	
	Method FastDraft(bol:Bool)
		If bol=True
			options.drawCircle=cp_mojo_DDrawCircle_Fast
			options.drawDot=cp_mojo_DDrawDot_Fast
			options.drawFatSegment=cp_mojo_DDrawFatSegment_Fast	
			options.drawPolygon=cp_mojo_DDrawPolygon_Fast	
			options.drawSegment=cp_mojo_DDrawSegment_Fast
			options.colorForShape=DebugColorForShape_Fast
		Else
			options.drawCircle=cp_mojo_DDrawCircle
			options.drawDot=cp_mojo_DDrawDot 	
			options.drawFatSegment=cp_mojo_DDrawFatSegment 	
			options.drawPolygon=cp_mojo_DDrawPolygon 	
			options.drawSegment=cp_mojo_DDrawSegment
			options.colorForShape=DebugColorForShape
		End
	End
	
	Method SetCanvas(cnv:Canvas)
		cp_GLOBAL_canvas=cnv
		w=cp_GLOBAL_canvas.Viewport.Width
		h=cp_GLOBAL_canvas.Viewport.Height
	End

	Method GetCanvasViewport()
		w=cp_GLOBAL_canvas.Viewport.Width
		h=cp_GLOBAL_canvas.Viewport.Height
	End
	
	Method SetCamera(view:cpVect,scl:Float)
		scale=scl
		viewpoint=view
	End
	
	Method CanvasToPhysics:cpVect(mouse:Vec2i)
		Local loc:cpVect
		loc.x=((mouse.x-w/2.0)/scale)+viewpoint.x
		loc.y=((mouse.y-h/2.0)/scale*y_axis_direction)+viewpoint.y
		Return loc
	End
End
	
	Function cp_mojo_DDrawCircle(center:cpVect , angle:cpFloat , radius:cpFloat ,outlineColor:cpSpaceDebugColor,fillColor:cpSpaceDebugColor,data:cpDataPointer)
	
		Local h:=CP_DEBUG_DRAWER.h
		Local w:=CP_DEBUG_DRAWER.w
		Local scale:=CP_DEBUG_DRAWER.scale
		Local y_axis_direction:=CP_DEBUG_DRAWER.y_axis_direction
		Local viewpoint:=CP_DEBUG_DRAWER.viewpoint
		Local axis:=cpv(Cos(angle),y_axis_direction*Sin(angle))
	
		Local cx:=(w/2.0)+(scale*(center.x-viewpoint.x))
		Local cy:=(h/2.0)+y_axis_direction*(scale*(center.y-viewpoint.y))
		
		cp_GLOBAL_canvas.Color = New Color(outlineColor.r,outlineColor.g,outlineColor.b,outlineColor.a)
		cp_GLOBAL_canvas.DrawCircle(cx,cy,radius*scale)
		
		cp_GLOBAL_canvas.Color = New Color(fillColor.r,fillColor.g,fillColor.b,fillColor.a)
		cp_GLOBAL_canvas.DrawCircle(cx,cy,radius*0.9*scale)
		cp_GLOBAL_canvas.Color = New Color(outlineColor.r/2.0,outlineColor.g/2.0,outlineColor.b/2.0,outlineColor.a)
		cp_GLOBAL_canvas.DrawLine(cx,cy,cx+axis.x*scale*radius,cy+y_axis_direction*axis.y*scale*radius)
	End
	Function cp_mojo_DDrawPolygon(vertexCount:int, vertices:const_cpVect Ptr,radius:cpFloat ,outlineColor:cpSpaceDebugColor , fillColor:cpSpaceDebugColor , data:cpDataPointer )'(vertices:cpVect Ptr, vertexCount:int, color:cpColor) 
	
			Local h:=CP_DEBUG_DRAWER.h
			Local w:=CP_DEBUG_DRAWER.w
			Local scale:=CP_DEBUG_DRAWER.scale
			Local y_axis_direction:=CP_DEBUG_DRAWER.y_axis_direction
			Local viewpoint:=CP_DEBUG_DRAWER.viewpoint
		
    		Local v:=New Float[vertexCount*2]
    		Local i:Int
    		Local l:=vertexCount-1
    		
    		'solid part
			cp_GLOBAL_canvas.Color = New Color(fillColor.r,fillColor.g,fillColor.b)

    		For Local i:=0 To vertexCount-1
    			v[i*2]=w/2.0+(vertices[i].x-viewpoint.x)*scale
    			v[i*2+1]=h/2.0+y_axis_direction*(vertices[i].y-viewpoint.y)*scale
    		Next
    		cp_GLOBAL_canvas.DrawPoly(v)
    		
    		'outline part
    		cp_GLOBAL_canvas.Color = New Color(outlineColor.r,outlineColor.g,outlineColor.b)
    		For i=0 To l
    			v[i*2]=w/2.0+(vertices[i].x-viewpoint.x)*scale
    			v[i*2+1]=h/2.0+y_axis_direction*(vertices[i].y-viewpoint.y)*scale
    		Next
    		For i=1 To l
    			cp_GLOBAL_canvas.DrawLine(v[(i-1)*2],v[(i-1)*2+1],v[i*2],v[i*2+1])
    		Next
    		i=l
    		cp_GLOBAL_canvas.DrawLine(v[0],v[1],v[i*2],v[i*2+1])
    End
    Function cp_mojo_DDrawSegment(p1:cpVect, p2:cpVect, color:cpSpaceDebugColor, data:cpDataPointer)
    	Local h:=CP_DEBUG_DRAWER.h
		Local w:=CP_DEBUG_DRAWER.w
		Local scale:=CP_DEBUG_DRAWER.scale
		Local y_axis_direction:=CP_DEBUG_DRAWER.y_axis_direction
		Local viewpoint:=CP_DEBUG_DRAWER.viewpoint
			
    	cp_GLOBAL_canvas.Color = New Color(color.r,color.g,color.b)
    	Local p1x:=(w/2.0)+(scale*(p1.x-viewpoint.x))
		Local p1y:=(h/2.0)+y_axis_direction*(scale*(p1.y-viewpoint.y))
		Local p2x:=(w/2.0)+(scale*(p2.x-viewpoint.x))
		Local p2y:=(h/2.0)+y_axis_direction*(scale*(p2.y-viewpoint.y))
    	cp_GLOBAL_canvas.DrawLine(p1x,p1y,p2x,p2y)
    End
    Function cp_mojo_DDrawFatSegment(p1:cpVect, p2:cpVect , radius:cpFloat, outlineColor:cpSpaceDebugColor, fillColor:cpSpaceDebugColor, data:cpDataPointer)'(p1:cpVect, p2:cpVect, color:cpColor) 
		Local h:=CP_DEBUG_DRAWER.h
		Local w:=CP_DEBUG_DRAWER.w
		Local scale:=CP_DEBUG_DRAWER.scale
		Local y_axis_direction:=CP_DEBUG_DRAWER.y_axis_direction
		Local viewpoint:=CP_DEBUG_DRAWER.viewpoint

    	cp_GLOBAL_canvas.Color = New Color(fillColor.r,fillColor.g,fillColor.b)
    	Local p1x:=(w/2.0)+(scale*(p1.x-viewpoint.x))
		Local p1y:=(h/2.0)+y_axis_direction*(scale*(p1.y-viewpoint.y))
		Local p2x:=(w/2.0)+(scale*(p2.x-viewpoint.x))
		Local p2y:=(h/2.0)+y_axis_direction*(scale*(p2.y-viewpoint.y))
    	cp_GLOBAL_canvas.DrawLine(p1x,p1y,p2x,p2y)
    End
    
Function DebugColorForShape:cpSpaceDebugColor(shape:cpShape Ptr,data:cpDataPointer)

	if cpShapeGetSensor(shape)
		return LAColor(1.0, 0.1)
	else
		Local body:=cpShapeGetBody(shape)
		
		
		if cpBodyIsSleeping(body)
			return LAColor(0.2, 1.0)
		else
			
			'creating various colors based on elasticity and friction -- more properties to go?
			
			Local val:UInt
			val=77777*cpShapeGetElasticity(shape)+888*cpShapeGetFriction(shape) 'add anything that can be added ?
			'val=11
			
			Local ha:UInt,hb:UInt,hc:UInt,hd:UInt,he:UInt,hf:Uint 
			
			ha=StringToULong("7ed55d16",16)
			hb=StringToULong("c761c23c",16)
			hc=StringToULong("165667b1",16)
			hd=StringToULong("d3a2646c",16)
			he=StringToULong("fd7046c5",16)
			hf=StringToULong("b55a4f09",16)
			
			val = (val+ha) + (val Shl 12)
			val = (val~hb) ~ (val Shr 19)
			val = (val+hc) + (val Shl 5)
			val = (val+hd) ~ (val Shl 9)
			val = (val+he) + (val Shl 3)
			val = (val~hf) ~ (val Shr 16)
					
			Local r:cpFloat,g:cpFloat,b:cpFloat
			
			r = ((val Shr 0) & 255)
			g = ((val Shr 8) & 255)
			b = ((val Shr 16) & 255)
			
			Local max := cpfmax(cpfmax(r, g), b)
			Local min := cpfmin(cpfmin(r, g), b)
						
			Local intensity:cpFloat
			If cpBodyGetType(body) = CP_BODY_TYPE_STATIC
				
				intensity = 0.45
			Else
				intensity = 0.85
			Endif
			
			if min = max
				return RGBAColor(intensity, 0.0, 0.0, 1.0)
			Else
				Local coef := intensity/(max - min)
				Return RGBAColor((r - min)*coef,(g - min)*coef,(b - min)*coef,1.0)
			Endif			
			
		Endif
	Endif
End
				
    
    Function cp_mojo_DDrawDot(size:cpFloat, p1:cpVect, color:cpSpaceDebugColor, data:cpDataPointer)
		Local h:=CP_DEBUG_DRAWER.h
		Local w:=CP_DEBUG_DRAWER.w
		Local scale:=CP_DEBUG_DRAWER.scale
		Local y_axis_direction:=CP_DEBUG_DRAWER.y_axis_direction
		Local viewpoint:=CP_DEBUG_DRAWER.viewpoint

    	cp_GLOBAL_canvas.Color = New Color(color.r,color.g,color.b)
		Local p1x:=(w/2.0)+(scale*(p1.x-viewpoint.x))
		Local p1y:=(h/2.0)+y_axis_direction*(scale*(p1.y-viewpoint.y))
    	cp_GLOBAL_canvas.DrawCircle(p1x,p1y,size*scale)
    End
    
    
    '
    '
    ' -----------------Fast Draws!! another DebugDraw implementation but with less details and no outlines and no fancy colors
    '
    '
    
    	Function cp_mojo_DDrawCircle_Fast(center:cpVect , angle:cpFloat , radius:cpFloat ,outlineColor:cpSpaceDebugColor,fillColor:cpSpaceDebugColor,data:cpDataPointer)
	
		Local h:=CP_DEBUG_DRAWER.h
		Local w:=CP_DEBUG_DRAWER.w
		Local scale:=CP_DEBUG_DRAWER.scale
		Local y_axis_direction:=CP_DEBUG_DRAWER.y_axis_direction
		Local viewpoint:=CP_DEBUG_DRAWER.viewpoint
		Local axis:=cpv(Cos(angle),y_axis_direction*Sin(angle))
	
		Local cx:=(w/2.0)+(scale*(center.x-viewpoint.x))
		Local cy:=(h/2.0)+y_axis_direction*(scale*(center.y-viewpoint.y))
		
		cp_GLOBAL_canvas.Color = Color.Blue'New Color(outlineColor.r,outlineColor.g,outlineColor.b,outlineColor.a)
		cp_GLOBAL_canvas.DrawCircle(cx,cy,radius*scale)
		
		cp_GLOBAL_canvas.Color = New Color(outlineColor.r/2.0,outlineColor.g/2.0,outlineColor.b/2.0,outlineColor.a)
		cp_GLOBAL_canvas.DrawLine(cx,cy,cx+axis.x*scale*radius,cy+y_axis_direction*axis.y*scale*radius)
	End
	Function cp_mojo_DDrawPolygon_Fast(vertexCount:int, vertices:const_cpVect Ptr,radius:cpFloat ,outlineColor:cpSpaceDebugColor , fillColor:cpSpaceDebugColor , data:cpDataPointer )'(vertices:cpVect Ptr, vertexCount:int, color:cpColor) 
	
			Local h:=CP_DEBUG_DRAWER.h
			Local w:=CP_DEBUG_DRAWER.w
			Local scale:=CP_DEBUG_DRAWER.scale
			Local y_axis_direction:=CP_DEBUG_DRAWER.y_axis_direction
			Local viewpoint:=CP_DEBUG_DRAWER.viewpoint
		
    		Local v:=New Float[vertexCount*2]
    		Local i:Int
    		Local l:=vertexCount-1
    		
    		'solid part
			cp_GLOBAL_canvas.Color = New Color(fillColor.r,fillColor.g,fillColor.b)

    		For Local i:=0 To vertexCount-1
    			v[i*2]=w/2.0+(vertices[i].x-viewpoint.x)*scale
    			v[i*2+1]=h/2.0+y_axis_direction*(vertices[i].y-viewpoint.y)*scale
    		Next
    		cp_GLOBAL_canvas.DrawPoly(v)
    	
    End
    Function cp_mojo_DDrawSegment_Fast(p1:cpVect, p2:cpVect, color:cpSpaceDebugColor, data:cpDataPointer)
    	Local h:=CP_DEBUG_DRAWER.h
		Local w:=CP_DEBUG_DRAWER.w
		Local scale:=CP_DEBUG_DRAWER.scale
		Local y_axis_direction:=CP_DEBUG_DRAWER.y_axis_direction
		Local viewpoint:=CP_DEBUG_DRAWER.viewpoint
			
    	cp_GLOBAL_canvas.Color = New Color(color.r,color.g,color.b)
    	Local p1x:=(w/2.0)+(scale*(p1.x-viewpoint.x))
		Local p1y:=(h/2.0)+y_axis_direction*(scale*(p1.y-viewpoint.y))
		Local p2x:=(w/2.0)+(scale*(p2.x-viewpoint.x))
		Local p2y:=(h/2.0)+y_axis_direction*(scale*(p2.y-viewpoint.y))
    	cp_GLOBAL_canvas.DrawLine(p1x,p1y,p2x,p2y)
    End
    Function cp_mojo_DDrawFatSegment_Fast(p1:cpVect, p2:cpVect , radius:cpFloat, outlineColor:cpSpaceDebugColor, fillColor:cpSpaceDebugColor, data:cpDataPointer)'(p1:cpVect, p2:cpVect, color:cpColor) 
		Local h:=CP_DEBUG_DRAWER.h
		Local w:=CP_DEBUG_DRAWER.w
		Local scale:=CP_DEBUG_DRAWER.scale
		Local y_axis_direction:=CP_DEBUG_DRAWER.y_axis_direction
		Local viewpoint:=CP_DEBUG_DRAWER.viewpoint

    	cp_GLOBAL_canvas.Color = New Color(fillColor.r,fillColor.g,fillColor.b)
    	Local p1x:=(w/2.0)+(scale*(p1.x-viewpoint.x))
		Local p1y:=(h/2.0)+y_axis_direction*(scale*(p1.y-viewpoint.y))
		Local p2x:=(w/2.0)+(scale*(p2.x-viewpoint.x))
		Local p2y:=(h/2.0)+y_axis_direction*(scale*(p2.y-viewpoint.y))
    	cp_GLOBAL_canvas.DrawLine(p1x,p1y,p2x,p2y)
    End
    
    
    Function DebugColorForShape_Fast:cpSpaceDebugColor(shape:cpShape Ptr,data:cpDataPointer)
    	Return ColorTocpSpaceDebugColor(New Color(0.2,0.8,0.1,0.9))
    End
				
    
    Function cp_mojo_DDrawDot_Fast(size:cpFloat, p1:cpVect, color:cpSpaceDebugColor, data:cpDataPointer)
		Local h:=CP_DEBUG_DRAWER.h
		Local w:=CP_DEBUG_DRAWER.w
		Local scale:=CP_DEBUG_DRAWER.scale
		Local y_axis_direction:=CP_DEBUG_DRAWER.y_axis_direction
		Local viewpoint:=CP_DEBUG_DRAWER.viewpoint

    	cp_GLOBAL_canvas.Color = New Color(color.r,color.g,color.b)
		Local p1x:=(w/2.0)+(scale*(p1.x-viewpoint.x))
		Local p1y:=(h/2.0)+y_axis_direction*(scale*(p1.y-viewpoint.y))
    	cp_GLOBAL_canvas.DrawCircle(p1x,p1y,size*scale)
    End
    
    
    
    
    '
    ' some supplements
    '
    '
    
    
    Function cpSpaceDebugColorToColor:Color(col:cpSpaceDebugColor) 'should use extension and operator to:
    	Return New Color(col.r,col.g,col.b,col.a)
    End
    Function ColorTocpSpaceDebugColor:cpSpaceDebugColor(col:Color) 'should use extension and operator to:
    	Local ret:cpSpaceDebugColor
    	ret.r=col.r
    	ret.g=col.g
    	ret.b=col.b
    	ret.a=col.a
    	Return ret
    End
    
Function RGBAColor:cpSpaceDebugColor(r:float, g:float, b:float, a:float)
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
    
