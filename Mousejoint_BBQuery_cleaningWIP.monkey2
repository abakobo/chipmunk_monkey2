

'this demo contains all shape types, a mouse joint with a distance query, a collision call back, and a BB query with a callBack function
'
' it needs to be cleared and better documented, some features could be split in several demo for better readability..

#Import "<std>"
#Import "<mojo>"
#Import "<chipmunk>"


'Mark's debugdraw
'#Import "chipmunkdebugger"

 'my debug draw with complete/fast option, camera using matrix, rounded end fatSegment and rounded corner polys (still WIP though)
#Import "chipmunkdebugdraw" 

Using std..
Using mojo..
Using chipmunk..



Global BBR:=New Recti (-105,10,-95,20)
Global BB:=cpBBNew(BBR.Left,BBR.Bottom,BBR.Right,BBR.Top)


Struct struct_for_callBack
 Field i:Int=15
 Field s:String="custostructo"
 Field d:double=12.21
End
Struct struct_for_shape
	Field f:Float=450.25
	Field str:String="shape data text"
End

Function BBCallBack (theShape:cpShape,data:Void Ptr)
  Print "somthing touched BB zone"
  
  	'checking the call back data
	Local CBDataPtr:struct_for_callBack Ptr
	CBDataPtr=Cast<struct_for_callBack Ptr>(data)
	Print CBDataPtr[0].s
	'checking the shape data
	Local ShapeDataVoidPtr:=cpShapeGetUserData(theShape)
	Local ShapeDataPtr:=Cast<struct_for_shape Ptr>(ShapeDataVoidPtr)
	Print ShapeDataPtr[0].str
End


Class HelloChipmunk Extends Window

	Field space:cpSpace
	Field ground:cpShape
	
	Field anyShapeData:=New struct_for_shape
	Field anyShapeDataVoidPtr:Void Ptr 
	
	Field ballBody:cpBody
	Field ballShape:cpShape
	Field ballShapeData:struct_for_shape

	Field ballBody2:cpBody
	Field ballShape2:cpShape

	Field polyBody:cpBody
	Field polyShape:cpShape
	
	Field segBody:cpBody
	Field segShape:cpShape
	
	Field mouse_body := cpBodyNewKinematic() 'the mouseBody will have forced movements ==> Kinematic. Kinematic bodies are not added to the space!
	Field mouseJoint:cpConstraint=Null 'initialised with Null to have consitent test on its existence
	
	Field debugger:=New ChipmunkDebugger
	
	Field fp:Void(cpShape, void ptr)
	Field callBack_data:Void ptr
	Field struct_for_callBack_data:= New struct_for_callBack
	
						
	' This Filter is for collision and queries filtering, it's the filter received by default by shapes and shall collide with any other.
	' The two last parameter are shown as bits because they are bitmasks
	Field FullGrabFilter:=cpShapeFilterNew(ULong(0),UInt(StringToULong("11111111111111111111111111111111",2)),UInt(StringToULong("11111111111111111111111111111111",2)))

	
	Method New()
	
		'Initializing BB CallBack stuffs
		fp=BBCallBack
		callBack_data=Cast<Void Ptr>(VarPtr struct_for_callBack_data)
		
		'creating default shape data pointer, each shape will need some or the BBcallback will throw a memory acces violation when reading the shape data
		anyShapeDataVoidPtr=Cast<Void Ptr>(Varptr anyShapeData)
	
	
		debugger.CompleteDraw() 'Fast draw enabled by default Complete shows sleep outline color, fill color, contacts, joints
		
		
		ClearColor=Color.Black

		'Create a new space and set its gravity to 100
		'		
		space=cpSpaceNew()
		space.Gravity=cpv( 0,100 )
		space.SleepTimeThreshold=2.0
		
		'Add three static line segment shapes for the grounds.
		'We'll make them slightly tilted so the balls will roll off.
		'We attach it to space.StaticBody to tell Chipmunk it shouldn't be movable.
		'We don't need to create bodies for them. Their body is space.StaticBody
		ground=cpSegmentShapeNew( space.StaticBody,cpv( -100,15 ),cpv( 100,-15 ),0 )
		ground.Friction=1
		ground.CollisionType=1
		space.AddShape( ground )
		ground.Elasticity=0.5 'so things can bounce on it..(if they also have some elasticity)
		ground.UserData=anyShapeDataVoidPtr
		
		Local tshape:=space.AddShape( cpSegmentShapeNew( space.StaticBody,cpv(-Width/2,Height/2-64),cpv(0,Height/2),0 ) )
		tshape.Friction=1
		tshape.CollisionType=1
		tshape.UserData=anyShapeDataVoidPtr

		tshape=space.AddShape( cpSegmentShapeNew( space.StaticBody,cpv(0,Height/2),cpv(Width/2,Height/2-64),0 ) )
		tshape.Friction=1
		tshape.CollisionType=1
		tshape.UserData=anyShapeDataVoidPtr
		
		'Now let's make a ball that falls onto the line and rolls off.
		'First we need to make a cpBody to hold the physical properties of the object.
		'These include the mass, position, velocity, angle, etc. of the object.
		'Then we attach collision shapes to the cpBody to give it a size and shape.
		
		Local mass:=1.0
		Local radius:=10.0
  
		'The moment of inertia is like mass for rotation
		'Use the cpMomentFor*() functions to help you approximate it.
		Local moment:=cpMomentForCircle( mass,0,radius,cpvzero )
		
		'The cpSpaceAdd*() functions return the thing that you are adding.
		'It's convenient to create and add an object in one line.
		ballBody=space.AddBody( cpBodyNew( mass,moment ) )
		ballBody.Position=cpv( 0,-100 )

		'Now we create the collision shape for the ball.
		'You can create multiple collision shapes that point to the same body.
		'They will all be attached to the body and move around to follow it.
		ballShape=space.AddShape( cpCircleShapeNew( ballBody,radius,cpvzero ) )
		ballShape.Friction=0.7
		ballShape.CollisionType=2
		' The ball receives a special shape UserData to check that call back works fine, some ptr casting 
		ballShapeData=New struct_for_shape
		ballShapeData.str="Ball n°1"
		Local voidDataPtr:=Cast<Void Ptr>(Varptr ballShapeData)
		ballShape.UserData=voidDataPtr
		
		Local ShapeDataVoidPtr:Void ptr
		ShapeDataVoidPtr=cpShapeGetUserData(ballShape)
	
		Local ShapeDataPtr:struct_for_shape Ptr
		ShapeDataPtr=Cast<struct_for_shape Ptr>(ShapeDataVoidPtr)
		Print ShapeDataPtr[0].str
		
		

		ballBody2=space.AddBody( cpBodyNew( mass,moment ) )
		ballBody2.Position=cpv( 50,-100 )
		
		ballShape2=space.AddShape( cpCircleShapeNew( ballBody2,radius,cpvzero ) )
		ballShape2.Friction=0.7
		ballShape2.CollisionType=2
		ballShape2.UserData=anyShapeDataVoidPtr
		
		'Now a pentagon...
		mass=0.3
		radius=30.0 'the radius of the pentagon
		Local cornerRadius:=3.0 'the radius of the added rounded corners
		
		Local NUM_VERTS:=5
		Local verts:=New cpVect[NUM_VERTS]
		For Local it:=0 Until NUM_VERTS
			Local angle:=TwoPi * it / NUM_VERTS
			verts[it]=cpv( radius*Cos( angle ),radius*Sin( angle ) )
		Next

		moment=cpMomentForPoly( mass,NUM_VERTS,verts.Data,cpvzero,0.0 )

		polyBody=space.AddBody( cpBodyNew( mass,moment ) )
		polyBody.Position=cpv( 50.0,-190.0 )
				
		polyShape=space.AddShape( cpPolyShapeNew( polyBody,NUM_VERTS,verts.Data,cpTransformIdentity,cornerRadius ) )
		polyShape.Friction=0.03
		polyShape.UserData=anyShapeDataVoidPtr
		
		
		'Now A "Fat" segment 
		
		mass = 1.2
		radius=5.0
		
		Local a := cpv(-15,  -15)
		Local b := cpv(15, 15)
	
		segBody = space.AddBody(cpBodyNew(mass, cpMomentForSegment(mass, a, b, radius)))
		segBody.Position= cpv(-15, -220)
	
		segShape = space.AddShape( cpSegmentShapeNew(segBody, a, b, radius))
		segShape.UserData=anyShapeDataVoidPtr
		cpShapeSetElasticity(segShape, 0.8)
		cpShapeSetFriction(segShape, 0.7)
		
		'Add collision handler...
		
		Local handler:=space.AddDefaultCollisionHandler()
				
		handler.beginFunc=Lambda:cpBool( arbiter:cpArbiter,space:cpSpace,data:cpDataPointer )

			Local a:cpShape,b:cpShape
			
			arbiter.GetShapes( Varptr a,Varptr b )
			
			Print "Collision! a="+a.CollisionType+", b="+b.CollisionType
			
			Return True
		End
		

	End

	Method OnRender( canvas:Canvas ) Override
	
		App.RequestRender()
	
		Const timeStep:=1.0/60.0
		
		space.StepTime( timeStep )
		canvas.Translate( Width/2,Height/2 )
		canvas.DrawRect(BBR) 'shows the BB defined in Global section (top of file)
		debugger.DebugDraw( canvas,space )
		
		'
		'	The mouse joint
		'		
		 If Mouse.ButtonPressed(MouseButton.Left) 'New click
			
			Local fetchRadius := 0.0
			
			'Transforming Mouse coordinates To a space's cpVect (due to canvas translated at half screen)
			Local mouseLocation:=cpv(Mouse.Location.x-(Width/2),Mouse.Location.y-(Height/2))

			
			Local info:cpPointQueryInfo 'will receive some infos about the query (distance,...). Not used here
			
			'Get the shape that is under the mouse, will return Null if nothing was under it
			Local grabbedShape := cpSpacePointQueryNearest(space,mouseLocation, fetchRadius, FullGrabFilter, Varptr info)
			
			'create a pivotJoint if there was a shape under the mouse
			If grabbedShape<>Null
				Local grabbedBody := cpShapeGetBody(grabbedShape)
				mouse_body.Position=mouseLocation
				mouseJoint = cpPivotJointNew2(mouse_body, grabbedBody, cpvzero, cpBodyWorldToLocal(grabbedBody, mouseLocation))
				cpConstraintSetMaxForce(mouseJoint,50000.0)
				cpConstraintSetErrorBias(mouseJoint,Pow(1.0 - 0.15, 60.0))
				cpSpaceAddConstraint(space, mouseJoint)
			End
			
		Endif
		
		If Mouse.ButtonDown(MouseButton.Left) 'If Button is still down
			mouse_body.Position=cpv( Mouse.Location.x-(Width/2),Mouse.Location.y-(Height/2))
			
		Else If mouseJoint<>Null 'If mouse is not down and a mouseJoint exists then destroy it
			cpSpaceRemoveConstraint(space, mouseJoint)
			cpConstraintFree(mouseJoint)
			mouseJoint = Null
		Endif
		' End of mouseJoint process
		
		'BB space query
		cpSpaceBBQuery(space,BB,FullGrabFilter,fp,callBack_data)
		
		
		If Keyboard.KeyDown(Key.F) Then debugger.FastDraw()
		If Keyboard.KeyDown(Key.C) Then debugger.CompleteDraw()
	
	End

	Method Cleanup()	'Yeah, right!
		cpShapeFree( ballShape )
		cpBodyFree( ballBody )
		cpShapeFree( ground )
		If mouseJoint<>Null
			cpSpaceRemoveConstraint(space, mouseJoint)
			cpConstraintFree(mouseJoint)
		Endif
		' and so on with every Body/shapes/constrains.
		cpSpaceFree( space )
		'Cleanup() must be called when you have several scenes or you'll leak memory.
		'Here Cleanup() is not called because all you can do is Quit.
	End

End

Function Main()

	New AppInstance
	
	New HelloChipmunk
	
	App.Run()
End
