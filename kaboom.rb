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

WORLD = Kaboom::World.new(1000, 350, 350 - (350 / 10))

class Input
  define_key SDL::Key::ESCAPE, :exit
end

def setup_sdl
  SDL.init(SDL::INIT_JOYSTICK)
  SDL::TTF.init
  SDL.set_video_mode(WORLD.w, WORLD.h, 16, SDL::HWSURFACE|SDL::DOUBLEBUF)
end

def kaboom!
  screen = setup_sdl()
  WORLD.screen = screen

  input = Input.new
  timer = FPSTimerLight.new
  timer.reset

  loop {
    WORLD.build
    res = WORLD.event(input)
    break if res == :stop
    timer.wait_frame {
      WORLD.tick
      screen.update_rect(0, 0, 0, 0)
    }
  }
end

kaboom!
