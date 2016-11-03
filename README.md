# chipmunk_monkey2
a set of debugDraw demos for the chipmunk module in monkey2

To use the debugDraw implementation you'll have to copy the "mx2\_module\_replace/chipmunk\_extern.monkey2" to your "*monkey2dir*/modules/chipmunk" directory. Because monkey2/c2mx2 can't manage "const" for external unimplemented function pointers and abstract methods for now. This has to be done by hand with some little hack. (a const_foo type defined in mx2 extern section)

The "radius" feature for fat segments and polygons is not implemented (next to come) so for now the debugDraw won't be consistent with radius other than 0 
