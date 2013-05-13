package input;

/**
 * Interface that is good for for keyboard polling emulators
 * @author Glenn Ko
 */
interface IKeyPoll
{

	function isDown(keyCode:Int):Bool;
    function isUp(keyCode:Int):Bool;
}