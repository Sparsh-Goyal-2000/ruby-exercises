# Using Ruby version: ruby 2.7.1p83 (2020-03-31 revision a0c7c23c9c) [x86_64-linux]
# Your Ruby code here
# frozen_string_literal: true

require 'csv'

# This DynamicClass is created to create classes and their methods run time
class DynamicClass
  attr_accessor :filename, :file_data, :class_name, :class_methods, :class_objects

  def initialize(filename)
    @filename = filename
    @file_data = CSV.read(filename, headers: true)
    @class_name = Object.const_set(create_dynamic_class, Class.new)
    @class_methods = file_data.headers
    @class_objects = []
    create_methods
  end

  def fetch_objects
    file_data.each do |data|
      object = class_name.new
      class_methods.each do |method|
        object.public_send("#{method}=", data[method])
      end
      class_objects << object		
    end
  end

  def display_objects
    class_objects.each_with_index do |object, index|
      puts "\n#{class_name} Object # : #{index + 1}"
      class_methods.each do |method|
        print "#{method} : "
        puts object.public_send(method)
      end
    end
  end

  private

  def create_dynamic_class
    File.basename(filename, '.csv').capitalize
  end

  def create_methods
    class_methods.each do |method| 
      class_name.class_eval { attr_accessor method }
    end
  end
end

if ARGV.empty?
  puts 'Please provide an input'
else
  my_class = DynamicClass.new(ARGV[0])
  my_class.fetch_objects
  my_class.display_objects
end
