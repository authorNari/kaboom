module Kaboom
  class HeapVisualizer
    attr_reader :h

    def initialize(screen)
      @screen = screen
      @mark_in_heap = [0]
      @h = 0
      @w = WORLD.w
    end

    def describe_mark_in_heap
      if (WORLD.frame % 20).zero?
        @all_obj_cnt = HeapInspector.mark_inspect!(@mark_in_heap)
        @h = 20
        @screen.fill_rect(0, 0, @w, @h, [0, 0, 0])
        if WORLD.visualize
          @h += (@all_obj_cnt / 1000 + 1)
          @screen.fill_rect(0, 0, @w, @h, [0, 0, 0])
          life = 0
          start_w = 0
          start_h = 0
          @mark_in_heap.each do |o|
            case o
            when true
              @screen.fill_rect(start_w, start_h, 1, 1, [0, 0, 255])
              life+=1
            when false
              @screen.fill_rect(start_w, start_h, 1, 1, [225, 225, 225])
              life+=1
            when 0
              @screen.fill_rect(start_w, start_h, @w - start_w, 1, [255, 255, 255])
              break
            end
            start_w += 1
            if (start_w % 1000).zero?
              start_w = 0
              start_h += 1
            end
          end
        end
        str = "GC Count : #{GC.count.to_s.rjust(5)} |"
        str << "All : #{@all_obj_cnt.to_s.rjust(5)} |"
        str << "Life : #{life.to_s.rjust(5)} |" if WORLD.visualize
        str << "Per Obj : #{WORLD.per_obj.to_s.rjust(5)}"
        WORLD.font.draw_solid_utf8(@screen, str, 2, @h - 20, 255,255,255)
        @screen.update_rect(0, 0, WORLD.w, @h)
      end
    end
  end
end
