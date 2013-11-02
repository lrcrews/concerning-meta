#*************************************************************************** 
## 
##  https://github.com/lrcrews/concerning-meta
##  
##  Copyright (c) 2013 L. Ryan Crews
##  
##  Permission is hereby granted, free of charge, to any person obtaining a copy
##  of this software and associated documentation files (the "Software"), to deal
##  in the Software without restriction, including without limitation the rights
##  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
##  copies of the Software, and to permit persons to whom the Software is
##  furnished to do so, subject to the following conditions:
##  
##  The above copyright notice and this permission notice shall be included in
##  all copies or substantial portions of the Software.
##  
##  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
##  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
##  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
##  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
##  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
##  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
##  THE SOFTWARE.
##  
##  tl;dr 
##    - feel free to use it for whatever you want
##    - don't expect me to fix issues you find (though I probably will)
##    - if you do use it, leave this
## 
#*************************************************************************** 

module MissingMethods
  extend ActiveSupport::Concern
    
  def method_missing(method_sym, *arguments, &block)
    method_as_string = method_sym.to_s
    puts "method missing :: #{method_as_string}"
    # This adds 'not_whatever?' methods for existing 'whatever?' methods.
    #
    # For example, 
    #   if 'user.admin?' is a valid method
    #   then 'user.not_admin?' is a valid method
    #
    # This is to increase readability as 'user.not_admin?' reads easier
    # than '!user.admin?'. 
    if method_as_string =~ /^not_(.*?)\?$/
      existing_method_name = method_as_string.slice(4,method_as_string.length-4)
      self.class.define_dynamic_not(method_sym, existing_method_name)
      self.send(method_sym)
    else
      super
    end
  end

  # Keep the respond_to up to date as well
  def respond_to?(method_sym, include_private = false)
    method_as_string = method_sym.to_s
    if method_as_string =~ /^not_(.*?)\?$/
      true
    else
      super
    end
  end


  module ClassMethods
  
    # Define the dynamic method so we only take the performance
    # hit of falling through to method_missing the first time.
    def define_dynamic_not(new_method, method_to_not)
      class_eval <<-RUBY
        def #{new_method}(original_method="#{method_to_not}")   # def not_admin?(original_method="admin?")
          !self.send(original_method)                           #   !self.admin?
        end                                                     # end
      RUBY
    end

  end

end
