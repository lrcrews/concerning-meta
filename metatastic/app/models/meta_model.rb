#******************************************
##
##  It's a model, that's possibly meta.
##
#******************************************

class MetaModel
  include MissingMethods
  
  def model?
  	true
  end

  def awesome?
    true
  end

  def horrible?
    false
  end
  
end
