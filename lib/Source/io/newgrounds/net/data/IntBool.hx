
package io.newgrounds.net.data;

abstract IntBool(Int)
{
    @:to
    inline public function toBool() return this != 0;
}