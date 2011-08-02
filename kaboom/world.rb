module Kaboom
  class World
    attr_reader :w, :h, :horizon, :frame
    attr_writer :screen
    attr_accessor :burden_obj, :visualize, :font, :big_font, :small_font,
                  :visualizing_sec, :rvalue_height, :init_obj,
                  :speed, :smart, :periodic_gc

    def initialize(w, h, horizon)
      @w = w
      @h = h
      @horizon = horizon
      @objs = []
      img1 = SDL::Surface.load("kaboom/img/kaboom1.bmp")
      img1.set_color_key(SDL::SRCCOLORKEY, Color::WHITE)
      img2 = SDL::Surface.load("kaboom/img/kaboom2.bmp")
      img2.set_color_key(SDL::SRCCOLORKEY, Color::WHITE)
      @kaboom_animation = [img1, img2, 0]
      @frame = 0
      @kaboom_start_frame = -1
      @kaboom_stop_frame = -1
      @screen = nil
      @burden_obj = 0
      @visualize = false
      @visualizing_sec = 20
      @rvalue_height = 1
      @speed = nil
      @smart = false
      @periodic_gc = false
    end

    def setup(screen, fonts={}, init_obj=0)
      @screen = screen
      @font = fonts[:normal]
      @big_font = fonts[:big]
      @small_font = fonts[:small]
      init_obj.times{ create_object(rand(@w), 10) }
    end

    def tick
      @frame += 1
      @objs.each{|o| o.live(@screen) }
      kaboom
      periodic_gc_start
    end

    def render_background
      @objs.each_with_index{|o, i| @objs[i] = nil if o.outed? }
      @objs.compact!
      @screen.fill_rect(0, 0, @w, @horizon, Color::WHITE)
      @screen.fill_rect(0, @horizon, @w, @h-@horizon, Color::BLACK)
      @font.draw_solid_utf8(@screen, "Obj : #{@objs.size}", 2, @horizon+4, *Color::WHITE)
    end

    def event(input)
      input.poll
      return :stop if input.exit
      if (@frame % 5).zero?
        x, y, lbutton, cbutton, rbutton = SDL::Mouse.state
        create_object(x, y) if rbutton
        if lbutton
          @kaboom_start_frame = @frame
          @kaboom_stop_frame = @frame + 10
          @kaboom_x = x - 50
          @kaboom_y = y - 50
          @objs.each{|o| o.check_kaboom(x, y) }
        end
        if input.gc
          GC.start
        end
      end
    end

    def create_object(x, y)
      @objs << Kaboom::Object.new(x, y)
    end

    private
    def kaboom
      if (@kaboom_start_frame..@kaboom_stop_frame).include?(@frame)
        @screen.put(@kaboom_animation[@kaboom_animation[-1]], @kaboom_x, @kaboom_y)
        if (@frame % 5).zero?
          index = @kaboom_animation[-1]
          index+=1
          index = 0 if index >= (@kaboom_animation.size-1)
          @kaboom_animation[-1] = index
        end
      end
    end

    def periodic_gc_start
      if (@frame % 100).zero?
        @screen.fill_rect(0, 0, @w, @horizon, Color::WHITE)
        @big_font.draw_solid_utf8(@screen, "GC.start!!", @w/2-150, @horizon/2-20, *Color::BLACK)
        @screen.update_rect(0, 0, @w, @horizon)
        GC.start
      end
    end
  end
end
