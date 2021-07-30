module ClassAttributeAccessors
  def cattr_reader(*symbols)
    options = extract_options(symbols)
    check_options(options)
    symbols.each do |sym|
      check_attr_name(sym)
      self.class.define_method("#{sym}") { class_variable_get("@@#{sym}") }  
      create_instance_methods(sym, options)
    end
  end
        
  def cattr_writer(*symbols)
    options = extract_options(symbols)
    check_options(options)
    symbols.each do |sym|
      check_attr_name(sym)
      self.class.define_method("#{sym}=", ) { |value| class_variable_set("@@#{sym}", value) }
      create_instance_methods(sym, options)
    end
  end
        
  def cattr_accessor(*symbols)
    cattr_reader(*symbols)
    cattr_writer(*symbols)
  end

  def create_instance_methods(symbol, options)
    return if options[:instance_accessor] == false
    define_method("#{symbol}") { self.class.class_variable_get("@@#{symbol}") } if options[:instance_reader] != false
    define_method("#{symbol}=") { |value| self.class.class_variable_set("@@#{symbol}", value) } if options[:instance_writer] != false
  end
  
  def extract_options(symbols)
    symbols.last.is_a?(::Hash) ? symbols.pop : {}
  end
  
  def check_options(options)
    raise NameError.new("Please pass reader/writer or accessor") if (options[:instance_reader] || options[:instance_writer]) && options[:instance_accessor]
  end
  
  def check_attr_name(symbol)
    raise NameError.new("invalid class attribute name: #{symbol}") unless symbol =~ /^[_A-Za-z]\w*$/
  end
end
  
class Person
  extend ClassAttributeAccessors
  cattr_accessor :hair_colors, instance_accessor: true
  cattr_accessor :eye_colors, instance_reader: false, instance_writer: true
# cattr_accessor :@hair
# cattr_accessor :eye_colors, instance_accessor: true, instance_writer: true
end

Person.hair_colors = [:brown, :black, :blonde, :red]
Person.eye_colors = [:black, :brown]
p Person.hair_colors
p Person.eye_colors

class Man < Person
end

p Man.hair_colors
Man.hair_colors << 'Blue'
p Man.hair_colors

p Person.hair_colors

p = Person.new
p p.hair_colors
p.eye_colors = [:blue]
p Person.eye_colors
# p p.eye_colors