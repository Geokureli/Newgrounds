package io.newgrounds.test;
class Test {
    
    dynamic public function onComplete():Void { }
    
    public function new() {}
    
    function complete():Void {
        
        trace('test completed: $this');
        onComplete();
    }
}
