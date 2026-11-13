
package ngio.data;

abstract IntBool(Int)
{
    @:to
    inline public function toBool() return this != 0;
}