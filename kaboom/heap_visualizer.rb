module Kaboom
  class HeapVisualizer
    attr_reader :h

    def initialize(screen)
      @screen = screen
      @mark_in_heap = [0]
      @h = 0
      @w = WORLD.w
      @marked_color = [0, 0, 255]
      @unmarked_color = [225, 225, 225]
      @empty_color = [255, 255, 255]
    end

    def describe_mark_in_heap
      if (WORLD.frame % WORLD.visualizing_sec).zero?
        @all_obj_cnt = HeapInspector.mark_inspect!(@mark_in_heap)
        @h = 0
        if WORLD.visualize
          @h += (@all_obj_cnt / 1000 + 1) * WORLD.rvalue_height
          @screen.fill_rect(0, 0, @w, @h, Color::WHITE)
          life = 0
          start_w = 0
          start_h = 0
          @mark_in_heap.each do |o|
            case o
            when true
              @screen.fill_rect(start_w, start_h, 1,
                                WORLD.rvalue_height, Color::BLACK)
              life+=1
            when false
              @screen.fill_rect(start_w, start_h, 1,
                                WORLD.rvalue_height, Color::GRAY)
              life+=1
            when 0
              @screen.fill_rect(start_w, start_h, @w - start_w,
                                WORLD.rvalue_height, Color::WHITE)
              break
            end
            start_w += 1
            if (start_w % 1000).zero?
              start_w = 0
              start_h += WORLD.rvalue_height
            end
          end
        end
        @screen.fill_rect(0, @h, @w, @h+20, [0, 0, 0])
        @h += 20
        str = "GC Count : #{GC.count.to_s.rjust(5)} |"
        str << "All : #{@all_obj_cnt.to_s.rjust(5)} |"
        str << "Life : #{life.to_s.rjust(5)} |" if WORLD.visualize
        str << "Per Burden : #{WORLD.burden_obj.to_s.rjust(5)}"
        WORLD.font.draw_solid_utf8(@screen, str, 2, @h - 20, *Color::WHITE)
        @screen.update_rect(0, 0, WORLD.w, @h)
      end
    end
  end
end
