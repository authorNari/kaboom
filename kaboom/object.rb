module Kaboom
  class Object
    IMAGES =
      ["kaboom/img/bou.bmp", "kaboom/img/snake.bmp",
       "kaboom/img/dog.bmp", "kaboom/img/ha.bmp",
       "kaboom/img/pen.bmp", "kaboom/img/rice.bmp",
      ]

    def initialize(x, y)
      im = SDL::Surface.load(IMAGES[rand(IMAGES.size)])
      @x, @y = x, y
      @w, @h = 50, 50
      @kaboom = false
      @kaboom_right_img = clean_bg(im.copy_rect(150, 0, 50, 50))
      @kaboom_left_img = clean_bg(im.copy_rect(150, 51, 50, 50))
      @def_right_img = @img = clean_bg(im.copy_rect(0, 0, 50, 50))
      @def_left_img = clean_bg(im.copy_rect(0, 51, 50, 50))
      @animate_right =
        [im.copy_rect(0, 51, 50, 50), im.copy_rect(50, 51, 50, 50),
         im.copy_rect(100, 51, 50, 50), im.copy_rect(50, 51, 50, 50), 0]
      @animate_right.map{|i| clean_bg(i)  unless i == 0}
      @animate_left =
        [im.copy_rect(0, 0, 50, 50), im.copy_rect(50, 0, 50, 50),
         im.copy_rect(100, 0, 50, 50), im.copy_rect(50, 0, 50, 50), 0]
      @animate_left.map{|i| clean_bg(i)  unless i == 0}
      @speed = (rand(5)+1)
      @move_methods = [:walk_right, :walk_left]
      @frame = 0
      @fall_speed = 0
      @kaboom_speed = 600 + rand(2) * 100
      @flyed = false
    end

    def live(screen)
      kaboom if @kaboom
      move if !@flyed && !@kaboom
      stand? ? stand_up : fall
      countup_frame
      screen.put(@img, @x, @y) if @img
    end

    def check_kaboom(x, y)
      diff_x = @x - x
      diff_x = 1 if diff_x.zero?
      diff_y = @y - y
      diff_y = 1 if diff_y.zero?
      if 100 > diff_y.abs + diff_x.abs
        @kaboom = true
        @kaboom_x_speed = @kaboom_speed / diff_x
        @kaboom_y_speed = @kaboom_speed / -(diff_y.abs)
      end
      if diff_x < 0
        @img = @kaboom_left_img
      else
        @img = @kaboom_right_img
      end
    end

    def outed?
      return true if @x < (0 - @w) || @y < (0 - @h)
      return true if @x > WORLD.w || @y > WORLD.h
      return false
    end

    private
    def move
      send(decide)
    end

    def decide
      if (@frame % (50 / @speed)).zero?
        return @move_method = @move_methods[rand(2)]
      end
      @move_method = :walk_right if @x < 0
      @move_method = :walk_left if (@x+@w) > WORLD.w
      return @move_method
    end

    def countup_frame
      @frame += 1
      @frame = 0 if @frame > 50000
    end

    def walk_right
      walk(@speed, @animate_right)
    end

    def walk_left
      walk(-(@speed), @animate_left)
    end

    def walk(move_rate, animate_img)
      animate(animate_img, walk_animate_rate(@speed))
      x_move(move_rate)
    end
    
    def walk_animate_rate(speed)
      step_rate = 4
      [[(4..7), 3], [(8..10), 2], [Range.new(11, 100, true), 1]].each{|i| step_rate = i.last if i.first.include? speed.abs}
      step_rate
    end

    def animate(imgs, frame_time)
      if (@frame % frame_time).zero?
        index = imgs.last
        index = 0 if imgs.size-1 == index
        @img = imgs[index]
        index += 1
        imgs[imgs.size-1] = index
      end
    end

    def clean_bg(img)
      img.set_color_key(SDL::SRCCOLORKEY, [255, 255, 255])
      img
    end

    def xy_move(x, y)
      @x += x
      @y += y
    end

    def x_move(x)
      @x += x
    end

    def y_move(y)
      @y += y
    end

    def stand?
      @y + @h >= WORLD.horizon
    end

    def stand_up
      @y = WORLD.horizon - @h
      @fall_speed = 0
      @flyed = false
    end

    def fall
      @flyed = true
      y_move(@fall_speed)
      @fall_speed += 1 if @fall_speed < 15
    end

    def kaboom
      x_move(@kaboom_x_speed)
      y_move(@kaboom_y_speed)
    end
  end
end
