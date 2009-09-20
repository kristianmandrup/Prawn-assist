require "open-uri"

module Prawn
  module Assist
    class Generate

      @@MAX_PAGE_HEIGHT = 600    
  
      def self.pdf(pdf, html, options = {:ypos => 30})
        # parse
        list = Prawn::Assist::Parse.html(html, options[:parse_options])

        # set options
        start_page_ypos = options[:start_page_ypos] || 30
        ypos = options[:ypos] || 30
        xpos = 0
        line_height = options[:line_height] || 12
        break_height = line_height + (line_height / 4)

        table_line_height = options[:table_line_height] || 16
        table_font_size = options[:table_font_size] || 12

        render_options = {:table_line_height =>  table_line_height, :table_default_cell_width => 120, :line_height => line_height, :break_height => break_height, :table_font_size => table_font_size}      
              
        # generate pdf      
        list[:html_list].each do |item|
          case item 
            when 'BREAK'
              pdf.move_down break_height
              ypos += break_height 
            when 'TABLE'
              if list[:tables].size > 0
                table = list[:tables].shift
                Prawn::Assist::set_positions(render_options, xpos, ypos)
                xpos, ypos = Prawn::Assist::Table.pdf(pdf, item, table, render_options)          
              end
            when 'IMG'                  
              if ypos > 600 # @@MAX_PAGE_HEIGHT                  
                 pdf.start_new_page 
                 ypos = start_page_ypos
              end
              if list[:images].size > 0
                img = list[:images].shift
                Prawn::Assist::set_positions(render_options, xpos, ypos)          
                # call img
                xpos, ypos = Prawn::Assist::Image.pdf(pdf, item, img,  render_options)
              end
            when 'NEW_PAGE'
              pdf.start_new_page      
            else
              breaks = item.scan(/<br>/i).length + item.scan(/<br\/>/i).length
              ypos = start_page_ypos if !ypos 
              ypos += (breaks * break_height)
              puts item
              pdf.text(item) if !item.blank?
          end
        end        
      end
            
    end
    
    def self.get_positions(render_options)
      return render_options[:xpos], render_options[:ypos]  
    end

    def self.set_positions(render_options, xpos, ypos)
      render_options[:xpos] = xpos
      render_options[:ypos] = ypos  
      render_options
    end
    
  end  
end