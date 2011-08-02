# kaboom
# (c)2010, nari
# http://www.narihiro.info/
#
# Ruby License
# http://www.ruby-lang.org/ja/LICENSE.txt

require 'rubygems'
require 'sdl'
require_relative 'lib/fpstimer.rb'
require_relative 'lib/input.rb'
require_relative 'kaboom/color'
require_relative 'kaboom/world'
require_relative 'kaboom/object'
require_relative 'kaboom/heap_visualizer'
require_relative 'kaboom/ext/heap_inspector'
require 'optparse'

GC::Profiler.enable
WORLD = Kaboom::World.new(1000, 350, 350 - (350 / 10))
@init_obj = 0

opts = OptionParser.new
opts.on("-b N", "--burden N", "burden level", Integer){|n| WORLD.burden_obj = n }
opts.on("-v", "--visualize", "show heap visualizer"){ WORLD.visualize = true }
opts.on("--sec N", "update sec for heap visualizer", Integer){|n| WORLD.visualizing_sec = n}
opts.on("--speed N", "speed for objects", Integer){|n| WORLD.speed = n}
opts.on("--smart", "more smart objects"){ WORLD.smart = true}
opts.on("--rvalue-height N", "object height for heap visualizer", Integer){|n| WORLD.rvalue_height = n }
opts.on("-o N", "create objects from beginning ", Integer){|n| @init_obj = n }
opts.on("--periodic-gc", "periodic GC.start"){ WORLD.periodic_gc = true}
opts.parse!(ARGV)

class Input
  define_key SDL::Key::ESCAPE, :exit
  define_key SDL::Key::G, :gc
end

def setup_sdl
  SDL.init(SDL::INIT_JOYSTICK)
  SDL::TTF.init
  screen = SDL.set_video_mode(WORLD.w, WORLD.h, 16, SDL::HWSURFACE|SDL::DOUBLEBUF)
  SDL::WM.set_caption("kaboom!!! | #{RUBY_DESCRIPTION}", "")
  return screen
end

def kaboom!
  screen = setup_sdl()
  font_path = File.join(File.dirname(__FILE__), 'kaboom/fonts/VeraMoBd.ttf')
  WORLD.setup(screen, 
              {:normal => SDL::TTF.open(font_path, 16),
                :big => SDL::TTF.open(font_path, 50),
                :small => SDL::TTF.open(font_path, 8)},
              @init_obj)

  input = Input.new
  visualizer = Kaboom::HeapVisualizer.new(screen)
  timer = FPSTimerLight.new
  timer.reset

  loop {
    WORLD.render_background
    res = WORLD.event(input)
    if res == :stop
      GC::Profiler.report
      puts "GC total time : #{GC::Profiler.total_time}"
      break
    end
    WORLD.tick
    visualizer.describe_mark_in_heap
    timer.wait_frame {
      screen.update_rect(0, visualizer.h, WORLD.w, WORLD.h-visualizer.h)
    }
  }
end

kaboom!
