require "open-uri"

module Prawn
  module Assist
    class Parse
      # Produces a PDF from a string containg HTML
      # Strips away some troublesome block-level tags which prawn format can't handle. Tries to handle images and tables somewhat.
      # Insert ::NEW_PAGE:: in HTML code to force a new page
    
      # Note: The internals of this method can be put on a .pdf-prawn page for debugging (uncomment: logger.debug(..) statements)    
        
      @@TABLE_MARKER = "TABLE"
      @@IMG_MARKER = "IMG"
      @@BREAK_MARKER = 'BREAK'
    
      @@DEFAULT_STRIP_TAGS = ['span', 'div', 'body', 'html', 'form', 'head'] 
      @@DEFAULT_ERASE_TAGS = ['object', 'script', 'applet', 'select', 'button', 'input', 'textarea', 'style', 'iframe', 'meta', 'link', 'hr']
      @@H_TAGS = ['h1', 'h2', 'h3', 'h4', 'h5', 'h6', 'h7', 'h8', 'h9']
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

      def self.html(html, options = {})

        @@DEFAULT_ERASE_TAGS.each do |tag|
          html.erase_tags!(tag)
        end
        
        # handle custom erase tags         
        if options[:erase_tags]
          options[:erase_tags].each do |tag|
            html.erase_tags!(tag)
          end
        end

        # use strip_tag method!
        @@DEFAULT_STRIP_TAGS.each do |tag|
          html.strip_tags!(tag)
        end

        # handle custom strip tags 
        if options[:strip_tags]
          options[:strip_tags].each do |tag|
            html.strip_tags!(tag)
          end
        end
                
        if options[:block_tags]
          bltags = options[:block_tags]
          if bltags.kind_of? String             
            if htags == 'all'
              @@BLOCK_TAGS.each do |tag|
                html.add_after_end_tag!(tag, '<br/>')
              end
            end          
            if bltags.include? '+'
              bltags.sub!('+', '')
              index = @@H_TAGS.index(bltags)
              bltags = @@H_TAGS[index..-1]
              bltags.each do |tag|
                html.add_after_end_tag!(tag, '<br/>')
              end                            
            end
          end
          
          if bltags.kind_of? Array 
            bltags.each do |tag|
              if tag.include? '+'
                tag.sub!('+', '')
                index = @@H_TAGS.index(tag)
                tags = @@H_TAGS[index..-1]
                tags.each do |tag2|
                  html.add_after_end_tag!(tag2, '<br/>')
                end                            
              else
                html.add_after_end_tag!(tag, '<br/>')
              end                            
            end
          end
        end
        
        if options[:strip_h_tags]
          htags = options[:strip_h_tags]
          if htags.kind_of? String             
            if htags == 'all'
              @@H_TAGS.each do |tag|
                html.strip_tags!(tag)
              end
            end          
            if htags.include? '+'
              htags.sub!('+', '')
              index = @@H_TAGS.index(htags)
              htags = @@H_TAGS[index..-1]
              htags.each do |tag|
                html.strip_tags!(tag)
              end                            
            end
          end        
          if htags.kind_of? Array 
            htags.each do |tag|
              html.strip_tags!(tag)
            end          
          end
        end
        
        doc = Nokogiri::HTML.parse(html)

        result = html

        doc.css('ul').each do |ul|
          puts "parsing ul"
          res = "<br/>"
          ul.css('li').each_with_index do |li, index|
            res << "- #{li.inner_html} <br/>"
          end
          result.replace_tag!('ul', res)
        end

        doc.css('ol').each do |ul|
          puts "parsing ol"
          res = "<br/>"
          ul.css('li').each_with_index do |li, index|
            res << "#{index+1}. #{li.inner_html} <br/>"
          end
          result.replace_tag!('ol', res)
        end


        tables = []

        # :headers: An array of table headers, either strings or Cells. [Empty]
        # :align_headers: Alignment of header text. Specify for entire header (:left) or by column ({ 0 => :right, 1 => :left}). If omitted, the header alignment is the same as the column alignment.
        # :header_text_color: Sets the text color of the headers
        # :header_color:  Manually sets the header color
        # :font_size: The font size for the text cells . [12]
        # :horizontal_padding:  The horizontal cell padding in PDF points [5]
        # :vertical_padding:  The vertical cell padding in PDF points [5]
        # :padding: Horizontal and vertical cell padding (overrides both)
        # :border_width:  With of border lines in PDF points [1]
        # :border_style:  If set to :grid, fills in all borders. If set to :underline_header, underline header only. Otherwise, borders are drawn on columns only, not rows
        # :border_color:  Sets the color of the borders.
        # :position:  One of :left, :center or n, where n is an x-offset from the left edge of the current bounding box
        # 
        # :width: A set width for the table, defaults to the sum of all column widths :column_widths: A hash of indices and widths in PDF points. E.g. { 0 => 50, 1 => 100 }
        # :row_colors:  An array of row background colors which are used cyclicly.
        # :align: Alignment of text in columns, for entire table (:center) or by column ({ 0 => :left, 1 => :center})
        # :minimum_rows:  The minimum rows to display on a page, including header.


        doc.css('table').each do |table|
          table_obj = {}
          header = table_obj[:headers] = []
          cls = table['class'] || ""
          table_obj[:border_style] = (cls if cls.includes_any?(['grid', 'underline'])) || 'grid'
          table_obj[:align] = table['align'] || 'left'
          table_obj[:width] = (table['width'].to_i if table['width'])
          table_obj[:height] = (table['width'].to_i if table['height'])
          table_obj[:border_width] = (table['border'].to_i if table['border']) || 1
          table_obj[:nobreak] = (table['nobreak'] && (table['nobreak'] != 'false'))
          rows = table_obj[:rows] = []
          # header
          table.css('tr').each_with_index do |tr, index|
            if index == 0
            
              tr.css('th').each do |th|
                th_hash = get_th_hash(th)
                header << th_hash
              end
              tr.css('td').each do |td|
                th_hash = get_th_hash(th)
                header << th_hash
              end
            else
              cells = []
              tr.css('td').each do |td|
                cells << td.inner_html
              end
              rows << cells
            end
          end
          tables << table_obj
        end

        # TODO: make strip_tag function, use better regexp!
        result.replace_tags_marker!('table', @@TABLE_MARKER)
        result.replace_start_tags_marker!('p', @@BREAK_MARKER)
        result.strip_tags!('p')

        result.remove_newlines!

        images = []
        doc.css('img').each do |img|
          images << get_img_hash(img)
        end

        result.replace_tags_marker!('img', @@IMG_MARKER)

        # puts result
        res_list = {:html_list => result.split(/:#:/), :tables => tables, :images => images}
      end
      
  protected  
      def self.get_img_hash(img)
        img_hash = {:src => img['src'].to_s, :width => img['width'].to_i || 200, :height => img['height'].to_i || 200, :title => img['title'] || img['alt'] }
        img_hash[:nobreak] = (img['nobreak'] && (img['nobreak'] != 'false'))        
        img_hash
      end

      def self.get_th_hash(th)
        return {:title => th.inner_html || "?", :width => th['width'].to_i, :align => th['align']}
      end       
    end # class
  end
end