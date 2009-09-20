require 'prawn'

html_full = "<p><i>Table</i> <table style='underline'> <tr><th>Numbers</th></tr> <tr><td>567</td></tr> <tr><td>123</td></tr> 
</table> <i>Alphabet soup</i> <ul><li>a</li> <li><b>b</b></li></ul></p> <span style='width:100'>hello</span>
<img src='http://prawn.majesticseacreature.com/media/prawn_logo.png' width='100' height='100' nobreak='true'/> 
<img src='http://prawn.majesticseacreature.com/media/prawn_logo.png' width='100' height='100' nobreak='true'/>
<img src='http://prawn.majesticseacreature.com/media/prawn_logo.png' width='100' height='100'/>
<p> <b>Numbered list</b> <ol> <li>Alpha</li> <li><i>Beta</i></li></ol> </p>"    

html_table = "<p><i>Table</i> <table class='text underline' border='5' width='200' align='center' nobreak='true'> <tr><th width='150' align='left'>Numbers</th></tr> <tr><td>567</td></tr> <tr><td>123</td></tr> 
</table> <table style='grid' width='200' align='center'> <tr><th width='150' align='left'>Names</th></tr> <tr><td>Mike</td></tr> <tr><td>Sam</td></tr> 
</table><i>Alphabet soup</i> <ul><li>a</li> <li><b>b</b></li></ul></p> <span style='width:100'>hello</span>
<p> <b>Numbered list</b> <ol> <li>Alpha</li> <li><i>Beta</i></li></ol> </p>"    

html_img = "<p> <i>Alphabet soup</i> <ul><li>a</li> <li><b>b</b></li></ul></p> <span style='width:100'>hello</span>
<img src='http://prawn.majesticseacreature.com/media/prawn_logo.png' width='100' height='100' nobreak='true'/> 
<img src='http://prawn.majesticseacreature.com/media/prawn_logo.png' width='100' height='100' nobreak='true'/>
<img src='http://prawn.majesticseacreature.com/media/prawn_logo.png' width='100' height='100'/>
<p> <b>Numbered list</b> <ol> <li>Alpha</li> <li><i>Beta</i></li></ol> </p>"    


html_tags = "
  <html>
    <head>
      <title>Hello</title>
      <meta sut/>
      <link blip/>
      <style>blip</style>
    </head>
    <body>
      <h1>blip</h1>
      <h2>blap</h2>
      <h3>blup</h3>
      <h4>blip</h4>
      <h5>blap</h5>
      <h6>blup</h6>
      <form>
        <input name='x'/>
        <textarea y=1/>
        <button x/>
      </form>
      <hr/>
    </body>
  </html>
"

pdf.tags :h1 => { :font_size => "16pt", :font_weight => :bold }, 
         :h2 => { :font_size => "14pt", :font_style => :italic },
         :h3 => { :font_size => "12pt", :font_style => :italic },
         :title => { :font_size => "24pt", :font_style => :bold }

options = {:line_height => 12, :font_size => "1em", :table_font_size => "0.8em", :table_line_height => 23, :start_page_ypos => 24, :table_default_cell_width => 60}  

# block_tags - add BREAK after rendering text!
parse_options = {:erase_tags => ['legend'], :strip_tags => ['dl', 'dd', 'dt', 'dfn'], :block_tags => ['title', 'h1+'], :strip_h_tags => 'h4+'}

options[:parse_options] = parse_options

Prawn::Assist::Generate.pdf(pdf, html_tags, options)


