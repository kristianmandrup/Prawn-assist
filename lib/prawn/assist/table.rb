module Prawn
  module Assist
    class Table

      # 
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


      # :table_font_size: 0.8em
      # :table_default_cell_width: 120
      # :line_height: 12
      # :break_height: 15
      # :table_row_height: 12

      def self.pdf(pdf, item, table, render_options)      
        break_height = render_options[:break_height] || 12
        row_height = render_options[:table_line_height] || 16
        border_style = (table[:border_style].to_sym if table[:border_style]) || :grid
        border_width = table[:border_width] || 1 
        table_rows = table[:rows].size + 1
        xpos, ypos = Prawn::Assist::get_positions(render_options)

        # border height
        border_height = Prawn::Assist::Table::get_border_height(table_rows, border_width,  border_style)
        
        table_height = table[:height] || ((table_rows * row_height) + border_height)
        table_width = table[:width] || Prawn::Assist::Table::get_table_width(table[:headers], render_options)             
        table_position = table[:align] || :center 
        table_headers = table[:headers]

        position = (xpos if xpos > 0) || table_position

        pdf.table table[:rows], 
           # TODO - use provided style
          :border_style => Prawn::Assist::Table::border_style(table),
          :row_colors => ["FFFFFF","DDDDDD"],
          :headers => Prawn::Assist::Table::text_headers(table_headers),
          :align => Prawn::Assist::Table::align_headers(table_headers), #OK
          :width => table_width,
          :border_width => border_width,
          :border_style => border_style,
          :position => position
                      
        border_adjust = Prawn::Assist::Table::get_border_height(table_rows, border_width -1,  border_style)                        
                    
        pdf.move_down break_height + border_adjust
        
        total_table_height = (table_height + break_height)
        
        ypos += total_table_height

        if table[:title]
          pdf.text table[:title]
          if table[:nobreak]
            pdf.move_up break_height
          end
        end

        if table[:nobreak]                    
          xpos += (table_width + 20) 
          ypos -= total_table_height
          pdf.move_up(total_table_height)
        else
          xpos = 0         
        end         

        Prawn::Assist::set_positions(render_options, xpos, ypos)                      
        return xpos, ypos        
      end

      def self.get_border_height(table_rows, border_width,  border_style)
        border_height = (table_rows * border_width)
        border_height = (3 * border_width) if border_style != :grid
        return border_height
      end 

      def self.border_style(table)
        table[:border_style].to_sym
      end

      def self.get_table_width(headers, render_options)
        width = 10
        headers.each do |header|
          width  += 100 # (header[:width] || render_options[:table_default_cell_width] || 100)
        end
        width
      end 

      def self.align_headers(headers)
        align = { 0 => :left, 1 => :center, 2 => :center, 3 => :center, 4 => :center, 5 => :center, 6 => :center}
        headers.each_with_index do |header, index|
          if header[:align]
            align[index] = header[:align].to_sym   
          end
        end
        align
      end

      def self.text_headers(headers)
        text_list = []
        headers.each_with_index do |header, index|
          if header[:title]
            text_list << (header[:title] || "?")
          end
        end
        text_list      
      end

    end # class
  end 
end