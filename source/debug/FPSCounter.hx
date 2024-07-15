package debug;

import flixel.FlxG;
import openfl.text.TextField;
import openfl.text.TextFormat;
import openfl.events.Event;
import openfl.system.System as OpenFlSystem;
import lime.system.System as LimeSystem;
import debug.MemoryUtil;

/**
    The FPS class provides an easy-to-use monitor to display
    the current frame rate and memory usage of an OpenFL project
**/
#if cpp
#if windows
@:cppFileCode('#include <windows.h>')
#elseif (ios || mac)
@:cppFileCode('#include <mach-o/arch.h>')
#else
@:headerInclude('sys/utsname.h')
#end
#end
class FPSCounter extends TextField
{
    /**
        The current frame rate, expressed using frames-per-second
    **/
    public var currentFPS(default, null):Int;

    @:noCompletion private var times:Array<Float>;

    public var os:String = '';

    // Memory counter variables
    private var memPeak:Float = 0;
    private static final BYTES_PER_MEG:Float = 1024 * 1024;
    private static final ROUND_TO:Float = 1 / 100;

    public function new(x:Float = 10, y:Float = 10, color:Int = 0x000000)
    {
        super();

        if (LimeSystem.platformName == LimeSystem.platformVersion || LimeSystem.platformVersion == null)
            os = '\nOS: ${LimeSystem.platformName}' #if cpp + ' ${getArch()}' #end;
        else
            os = '\nOS: ${LimeSystem.platformName}' #if cpp + ' ${getArch()}' #end + ' - ${LimeSystem.platformVersion}';

        positionFPS(x, y);

        currentFPS = 0;
        selectable = false;
        mouseEnabled = false;
        defaultTextFormat = new TextFormat("_sans", 14, color);
        width = FlxG.width;
        multiline = true;
        text = "FPS: ";

        times = [];
    }

    var deltaTimeout:Float = 0.0;

    // Event handler for FPS calculation and text update
    private override function __enterFrame(deltaTime:Float):Void
    {
        // prevents the overlay from updating every frame, why would you need to anyways
        if (deltaTimeout > 1000) {
            deltaTimeout = 0.0;
            return;
        }

        final now:Float = haxe.Timer.stamp() * 1000;
        times.push(now);
        while (times[0] < now - 1000) times.shift();

        currentFPS = times.length < FlxG.updateFramerate ? times.length : FlxG.updateFramerate;       
        updateText();
        deltaTimeout += deltaTime;

        var mem:Float = Math.round(OpenFlSystem.totalMemory / BYTES_PER_MEG / ROUND_TO) * ROUND_TO;

        if (mem > memPeak) memPeak = mem;
    }

    // Update the text displayed for both FPS and RAM
    public function updateText():Void
    {
        text = 
        'FPS: $currentFPS' + 
        '\nRAM: ${Math.round(OpenFlSystem.totalMemory / BYTES_PER_MEG / ROUND_TO) * ROUND_TO}mb / ${memPeak}mb';

        textColor = 0xFFFFFFFF;
        if (currentFPS < FlxG.drawFramerate * 0.5)
            textColor = 0xFFFF0000;
    }

    public inline function positionFPS(X:Float, Y:Float, ?scale:Float = 1){
        scaleX = scaleY = #if android (scale > 1 ? scale : 1) #else (scale < 1 ? scale : 1) #end;
        x = FlxG.game.x + X;
        y = FlxG.game.y + Y;
    }

    #if cpp
    #if windows
    @:functionCode('
        SYSTEM_INFO osInfo;

        GetSystemInfo(&osInfo);

        switch(osInfo.wProcessorArchitecture)
        {
            case 9:
                return ::String("x86_64");
            case 5:
                return ::String("ARM");
            case 12:
                return ::String("ARM64");
            case 6:
                return ::String("IA-64");
            case 0:
                return ::String("x86");
            default:
                return ::String("Unknown");
        }
    ')
    #elseif (ios || mac)
    @:functionCode('
        const NXArchInfo *archInfo = NXGetLocalArchInfo();
        return ::String(archInfo == NULL ? "Unknown" : archInfo->name);
    ')
    #else
    @:functionCode('
        struct utsname osInfo{};
        uname(&osInfo);
        return ::String(osInfo.machine);
    ')
    #end
    @:noCompletion
    private function getArch():String
    {
        return null;
    }
    #end
}
