module Prawn
  module Assist
  
    # Usage:
    #  
    # require 'nokogiri'
    # require 'prawn'
    #
    # string = "<p><i>Alphabet soup</i> <ul><li>a</li> <li><b>b</b></li>  </ul></p> <p> <b>Numbered list</b> <ol> <li>Alpha</li> <li><i>Beta</i></li></ol> </p>"    
    # 
    # list = Prawn::parse(string)
    # 
    # list.each do |item|  
    #   pdf.move_down(12)
    #   logger.debug(item)  
    #   pdf.text item
    # end
      
    def self.parse(html)
  
      doc = Nokogiri::HTML.parse(html)
  
      result = html
      doc.css('ul').each do |ul|
        puts "parsing ul"      
        res = "<br/>"
        ul.css('li').each_with_index do |li, index|      
          res << "- #{li.inner_html} <br/>"
        end
        result.sub!(/<ul>.*?<\/ul>/, res)
      end

      doc.css('ol').each do |ul|
        puts "parsing ol"
        res = "<br/>"
        ul.css('li').each_with_index do |li, index|
          res << "#{index+1}. #{li.inner_html} <br/>"
        end
        result.sub!(/<ol>.*?<\/ol>/, res)      
      end

      result.gsub!(/<p>/, '#BREAK#')
      result.gsub!(/<\/p>/, '')
              
      # puts result
      res_list = result.split(/#BREAK#/)
  
      res_list
    end
  end
end