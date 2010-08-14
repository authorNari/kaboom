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
require_relative 'kaboom/world'
require_relative 'kaboom/object'
require_relative 'kaboom/heap_visualizer'
require_relative 'kaboom/ext/heap_inspector'
require 'optparse'

GC::Profiler.enable
WORLD = Kaboom::World.new(1000, 350, 350 - (350 / 10))

opts = OptionParser.new
opts.on("--per-obj N", Integer){|n| WORLD.per_obj = n }
opts.on("-v", "--visualize"){|value| WORLD.visualize = true }
opts.parse!(ARGV)

class Input
  define_key SDL::Key::ESCAPE, :exit
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
  WORLD.screen = screen
  WORLD.font = SDL::TTF.open(File.join(File.dirname(__FILE__), 'kaboom/fonts/VeraMoBd.ttf'), 16)

  input = Input.new
  visualizer = Kaboom::HeapVisualizer.new(screen)
  timer = FPSTimerLight.new
  timer.reset

  loop {
    WORLD.build
    res = WORLD.event(input)
    if res == :stop
      GC::Profiler.report
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
