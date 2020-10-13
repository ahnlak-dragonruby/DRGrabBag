# DRGrabBag

This is collection of (hopefully) useful classes and mixins for DragonRuby, which
have grown out of my own needs and which I'm now putting here in the hopes that
it will be helpful to someone else too.

Every file is standalone; simply grab whichever ones are useful to you and drop
them into your project (not forgetting to `require` them into your `main.rb`!).

Each file has a version number at the top; changes *shouldn't* ever be breaking,
unless it's fixing unintended behaviour that needs to be broken.


## Mixins

After finding myself duplicating code in just about every class I create, I've
created these mixins to reduce my typing. They can simply be added to any class
by adding `include Ahnlak::MixinName` to your definition.


### MixinColourable

Adds `r`, `g`, `b` and `a` values to a sprite.

Provides a `colourable` method which takes `r`, `g`, `b` and `a` values, and an
optional `speed` parameter. Without a `speed`, the sprites colour values are 
immediately set. *With* a `speed`, the colour is slowly transitioned from the 
current values to the new ones, over the course of `speed` frames.

The `colourable_array` method takes an array of four `rbga` values, and an optional
`speed` parameter, to perform the same job as `colourable`.

`colourable_sequence` takes an array of colour arrays, plus a `speed` parameter.
This will transition from the first colour in the array, through to the second,
and so on, each time taking `speed` frames to move from colour to colour. At the
end of the sequence, the colour will be set to the last colour in the provided 
array.

`colourable_cycle` does the same job as `colourable_sequence`, but once the end
of the array is reached, the colour sequence cycles back to the beginning.

The `colourable_changing?` method returns true if there is currently a colour 
change happening, or false if it is currently stable.

Finally, the `colourable_update` method **must** be called every tick, to allow
for the colour values to be updated.


### MixinSerializable

Adds `serialize`, `inspect` and `to_s` methods to any class, to aid debugging.
This will add a dump of all instance variables, as well as the name of the 
actual class, whenever DragonRuby hits a problem - also in your own debugging
output, simply by using `puts` to output an instance of your class.

The `serializable_without` method allows you to specify the name of an instance
variable that should not appear in the serialization. This can be useful for
classes which maintain a reference to `@args`, which can be quite huge when
serialized.