String.class_eval do 
  def last(n)
    self[-n,n]
  end  

  def remove_newlines!
    self.gsub!(/\n/, '')    
  end  

  def includes_any?(list)
    return false if self == nil
    list.each do |item|
      return true if self.include?(item)
    end
    false
  end  

  # OK
  def strip_tags!(tag)
    self.gsub!(/<\/?#{tag}[^>]*>/i, "")      
  end

  # encure matches newlines (any white-space!) between tag markers 
  def replace_tag!(tag, replace_str)
    self.sub!(/<#{tag}[^>]*>(.|\n)*?<\/#{tag}>/i, replace_str)
  end

  def erase_tags!(tag)
    self.replace_tags!(tag, '')
  end

  def add_after_end_tag!(tag, replace_str)
    self.gsub!(/<\/#{tag}>/i, "\1#{replace_str}")    
  end

  # encure matches newlines (any white-space!) between tag markers 
  def replace_tags!(tag, replace_str)
    self.gsub!(/<#{tag}[^>]*>(.|\n)*?<\/#{tag}>/i, replace_str)
    self.gsub!(/<#{tag}[^>]*\/>/i, replace_str)
  end

  # encure matches newlines (any white-space!) between tag markers 
  def replace_tags_marker!(tag, marker)
    sep = ":#:"
    marker = "#{sep}#{marker}#{sep}"
    self.gsub!(/<#{tag}[^>]*>(.|\n)*?<\/#{tag}>/i, marker)
    self.gsub!(/<#{tag}(.|\n)*?\/>/i, marker)
  end  

  # encure matches newlines (any white-space!) between tag markers 
  def replace_start_tags_marker!(tag, marker)
    sep = ":#:"
    marker = "#{sep}#{marker}#{sep}"
    self.gsub!(/<#{tag}[^>]*>/i, marker)
    self.gsub!(/<#{tag}(.|\n)*?\/>/i, marker)
  end   
end
