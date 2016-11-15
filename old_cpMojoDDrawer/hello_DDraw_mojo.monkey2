
#Import "<std>"
#Import "<mojo>"
#Import "<chipmunk>"
#Import "cpMojoDDrawer/cp_mojo_debugdraw.monkey2"


Using std..
Using mojo..
Using chipmunk..



Class HelloChipmunk Extends Window

	Field space:cpSpace Ptr
	Field ground:cpShape Ptr
	Field ballBody:cpBody Ptr
	Field ballBody2:cpBody Ptr
	Field polyBody:cpBody Ptr
	Field ballShape:cpShape Ptr
	Field ballShape2:cpShape Ptr
	Field polyShape:cpShape Ptr
	Field verts:cpVect[]
	
	Field IsSet:=false
	
	Method New()
	
		
		ClearColor=Color.Black
	
		'Create an empty space.
		space=cpSpaceNew()
		cpSpaceSetGravity( space,cpv( 0,300 ) )
		
		'Add a static line segment shape for the ground.
		'We'll make it slightly tilted so the ball will roll off.
		'We attach it to space->staticBody to tell Chipmunk it shouldn't be movable.
		ground=cpSegmentShapeNew( cpSpaceGetStaticBody( space ),cpv( -100,-15 ), cpv( 100,-15 ),0 )
		cpShapeSetFriction( ground,1 )
		cpShapeSetElasticity ( ground,0.9 )
		cpSpaceAddShape( space,ground )
		
		'Now let's make a ball that falls onto the line and rolls off.
		'First we need to make a cpBody to hold the physical properties of the object.
		'These include the mass, position, velocity, angle, etc. of the object.
		'Then we attach collision shapes to the cpBody to give it a size and shape.
		
		Local radius:=10
		Local mass:=1.0
  
		'The moment of inertia is like mass for rotation
		'Use the cpMomentFor*() functions to help you approximate it.
		Local moment:=cpMomentForCircle( mass,0,radius,cpvzero )
		
		'The cpSpaceAdd*() functions return the thing that you are adding.
		'It's convenient to create and add an object in one line.
		ballBody=cpSpaceAddBody( space,cpBodyNew( mass,moment ) )
		cpBodySetPosition( ballBody,cpv( 0,-150 ) )
		
		'Now we create the collision shape for the ball.
		'You can create multiple collision shapes that point to the same body.
		'They will all be attached to the body and move around to follow it.
		ballShape=cpSpaceAddShape( space,cpCircleShapeNew( ballBody,radius,cpvzero ) )
		cpShapeSetFriction( ballShape,0.7 )
		cpShapeSetElasticity ( ballShape,0.3 )
		
		
		'---Second circle
		
		
		mass=2.0
  
		'The moment of inertia is like mass for rotation
		'Use the cpMomentFor*() functions to help you approximate it.
		moment=cpMomentForCircle( mass,0,radius,cpvzero )
		
		'The cpSpaceAdd*() functions return the thing that you are adding.
		'It's convenient to create and add an object in one line.
		ballBody2=cpSpaceAddBody( space,cpBodyNew( mass,moment ) )
		cpBodySetPosition( ballBody2,cpv( -8,-111 ) )
		
		'Now we create the collision shape for the ball.
		'You can create multiple collision shapes that point to the same body.
		'They will all be attached to the body and move around to follow it.
		ballShape2=cpSpaceAddShape( space,cpCircleShapeNew( ballBody2,radius,cpvzero ) )
		cpShapeSetFriction( ballShape2,0.3 )
		cpShapeSetElasticity ( ballShape2,0.7 )
		
		'---Pentagon
		
		
		mass = 0.3
		Local NUM_VERTS := 5
		
		verts=New cpVect[NUM_VERTS]
		for Local it:=0 To NUM_VERTS-1
			Local angle:cpFloat
			angle = -2.0*Pi*it/(1.0*NUM_VERTS)
			verts[it] = cpv(30*Cos(angle), 30*Sin(angle))
		Next
		
		polyBody = cpSpaceAddBody(space, cpBodyNew(mass, cpMomentForPoly(mass, NUM_VERTS, Varptr verts[0], cpvzero, 0.0)))
		cpBodySetPosition(polyBody, cpv(0.0, -190.0))
		
		polyShape=cpSpaceAddShape(space, cpPolyShapeNew(polyBody, NUM_VERTS, Varptr verts[0], cpTransformIdentity, 0.0))
		cpShapeSetFriction( polyShape,0.03 )
		
		'
		'  ---- Debug draw setup
		'
	
	End
	
	Method OnRender( canvas:Canvas ) Override
	
	
		App.RequestRender()
		
		
		'It is *highly* recommended to use a fixed size time step.
		Local timeStep:=1.0/60.0
		
		cpSpaceStep( space,timeStep )
		
		CP_DEBUG_DRAWER.SetCanvas(canvas) ' you MUST set the canvas before calling cpSpaceDebugDraw or you'll get a memory acces violation!
		CP_DEBUG_DRAWER.SetCamera(cpv(0,-90),1.5)
		cpSpaceDebugDraw(space,Varptr CP_DEBUG_DRAWER.options)
		
		
		canvas.DrawText("FPS: "+App.FPS,10,10)		
		
	End
	
	Method Cleanup()	'Yeah, right!
		cpShapeFree( ballShape )
		cpBodyFree( ballBody )
		cpShapeFree( ground )
		cpSpaceFree( space )
	End

End

Function Main()

	New AppInstance
	
	New HelloChipmunk
	
	App.Run()
End
