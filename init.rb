# Load CoreExtensions
# Dir[File.join("#{File.dirname(__FILE__)}", 'lib', 'prawn', '**', '*.rb')].each do |f|
#   extension_module = f.sub(/(.*)(prawn.*)\.rb/,'\2').classify.constantize
#   base_module = f.sub(/(.*prawn.)(.*)\.rb/,'\2').classify.constantize
#   base_module.class_eval { include extension_module }
# end

require 'prawn/assist/include'