module Prawn
  module Assist
    class Image
      def self.pdf(pdf, item, img,  render_options)
        xpos, ypos = Prawn::Assist::get_positions(render_options)      
        if img[:src]
          options = {:position => (xpos if xpos > 0) || :left, :vposition => render_options[:ypos]}
          options[:width] = img[:width] if img[:width] > 0
          options[:height] = img[:height] if img[:height] > 0

          ypos = render_options[:ypos]

          pdf.image open(img[:src]), options 
          break_height = (render_options[:break_height] || 12)

          pdf.move_down break_height
          total_height = (img[:height] + break_height)
          ypos += total_height

          if img[:title]
            pdf.text img[:title]
            ypos += break_height             
          end

          if img[:nobreak]                    
            xpos += (img[:width] + 20) 
            ypos -= total_height
            pdf.move_up total_height
            if img[:title]
              ypos -= break_height
            end
          else
            xpos = 0         
          end 
          Prawn::Assist::set_positions(render_options, xpos, ypos)                                  
        end
        return xpos, ypos
      end
    end
  end
end