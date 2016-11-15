
#Import "<std>"
#Import "<mojo>"
#Import "<chipmunk>"
'#Import "cpMojoDDrawer/cp_mojo_debugdraw.monkey2"
#Import "chipmunkdebugger"


Using std..
Using mojo..
Using chipmunk..

Global w_width:=1000 'initial window size
Global w_height:=700

Class HelloChipmunk Extends Window

	Field space:cpSpace 
	Field ground:cpShape 
	Field ballBody:=New cpBody [1600]
	Field polyBody:=New cpBody [400]
	Field ballShape:=New cpShape [1600]
	Field polyShape:=New cpShape [400]
	Field verts:cpVect[]
	
	Field debugger:=New ChipmunkDebugger
	
	Field stepCount:=0
	
	'Field MyDDrawer:
	
	'Field DDCircle:cp_mojo_DDrawCircle()
	
	Method New( title:String,width:Int,height:Int,flags:WindowFlags=WindowFlags.Resizable )
				
		Super.New( title,width,height,flags )
		
		
		ClearColor=Color.Black
	
		'Create an empty space.
		space=cpSpaceNew()
		cpSpaceSetGravity( space,cpv( 0,10 ) )
		
		'cpSpaceUseSpatialHash(space, 5.0, 100000)
		
		'Add a static line segment shape for the ground.
		'We'll make it slightly tilted so the ball will roll off.
		'We attach it to space->staticBody to tell Chipmunk it shouldn't be movable.
		ground=cpSegmentShapeNew( cpSpaceGetStaticBody( space ),cpv( -200,-70 ), cpv( 100,-70 ),0 )
		cpShapeSetFriction( ground,1 )
		cpShapeSetElasticity ( ground,0.9 )
		cpSpaceAddShape( space,ground )
		
		'Now let's make a ball that falls onto the line and rolls off.
		'First we need to make a cpBody to hold the physical properties of the object.
		'These include the mass, position, velocity, angle, etc. of the object.
		'Then we attach collision shapes to the cpBody to give it a size and shape.
		
		Local radius:=1.0
		Local mass:=Pi
		Local moment:cpFloat
  		For Local i:=0 To 50
  		For Local j:=0 To 30
  		
		moment=cpMomentForCircle( mass,0,radius,cpvzero )
		
		ballBody[i+j*51]=space.AddBody( cpBodyNew( mass,moment ) )
		 ballBody[i+j*51].Position=cpv( -90+i*2.2+j*0.2,-150+j*2.2 ) 

		ballShape[i+j*51]=space.AddShape( cpCircleShapeNew( ballBody[i+j*51],radius,cpvzero ) )
		cpShapeSetFriction( ballShape[i+j*51],0.1 )
		cpShapeSetElasticity ( ballShape[i+j*51],0.0+Rnd(0.002) ) 'rnd is for colors, colors are based on elastcity for now but should be a mix of all properties
		Next
		Next

		
		'---Pentagons
		
		Local NUM_VERTS := 5
		
		verts=New cpVect[NUM_VERTS]
		for Local it:=0 To NUM_VERTS-1
			Local angle:cpFloat
			angle = -2.0*Pi*it/(1.0*NUM_VERTS)
			verts[it] = cpv(3*Cos(angle), 3*Sin(angle))
		Next
		mass = 21.4
		
		For Local i:=0 To 19
		For Local j:=0 To 9
		
		polyBody[i+j*20] = cpSpaceAddBody(space, cpBodyNew(mass, cpMomentForPoly(mass, NUM_VERTS, Varptr verts[0], cpvzero, 0.0)))
		cpBodySetPosition(polyBody[i+j*20], cpv(-100.0+i*6.5, -220.0+j*6.5))
		
		polyShape[i+j*20]=cpSpaceAddShape(space, cpPolyShapeNew(polyBody[i+j*20], NUM_VERTS, verts.Data, cpTransformIdentity, 0.0))
		cpShapeSetFriction( polyShape[i+j*20],0.1 )
		cpShapeSetElasticity ( polyShape[i+j*20],0.0+Rnd(0.002) ) 'rnd is for colors, colors are based on elastcity for now but should be a mix of all properties (mass,moment,friction,elsticity,...)
		
		Next
		next
		
		
		
		'
		'  ---- Debug draw setup
		'
		
		'CP_DEBUG_DRAWER.options.flags=CP_SPACE_DEBUG_DRAW_SHAPES ' by default there is also constrains and contact points
		'CP_DEBUG_DRAWER.FastDraft(True) 'Set to true to get a less beautifull but faster render
		
	End
	
	Method OnRender( canvas:Canvas ) Override
	
	
		App.RequestRender()
		
		
		'It is *highly* recommended to use a fixed size time step.
		'Local timeStep:=1.0/60.0
		
		'cpSpaceStep( space,timeStep )
		'stepCount=stepCount+1
		'		App.RequestRender()
	
		Const timeStep:=1.0/60.0
		
		space.StepTime( timeStep )
		
'		Local rot:=ballBody.Rotation
'		Local pos:=ballBody.Position
'		Local vel:=ballBody.Velocity
'		Print "ball rot="+ATan2( rot.y,rot.x )+", pos.x="+pos.x+", pos.y="+pos.y+", vel.x="+vel.x+", vel.y="+vel.y
		
		canvas.Translate( Width/2,Height/2 )
		
		debugger.DebugDraw( canvas,space )
		'CP_DEBUG_DRAWER.SetCanvas(canvas)
		'CP_DEBUG_DRAWER.SetCamera(cpv(-50,-120),3.5)
		'cpSpaceDebugDraw(space,Varptr CP_DEBUG_DRAWER.options)
		'canvas.Color=Color.White
		canvas.DrawText("FPS: "+App.FPS,10,10)
		canvas.DrawText("step: "+stepCount,10,40)
		
		
	End
	
	Method Cleanup()	'Yeah, right!
		cpShapeFree( ballShape[0] )
		cpBodyFree( ballBody[0] )
		cpShapeFree( ground )
		cpSpaceFree( space )
	End

End

Function Main()

	New AppInstance
	
	New HelloChipmunk( "chipmunk_test",w_width,w_height )
	
	App.Run()
End
