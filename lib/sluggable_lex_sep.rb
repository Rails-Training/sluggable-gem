module SluggableLexSep extend ActiveSupport::Concern
  
  included do
    before_save :generate_slug
    class_attribute :slug_column
  end
  
  def to_param
    self.slug
  end
  
  def generate_slug
    the_slug = to_slug(self.send(self.class.slug_column.to_sym))
    obj = self.class.find_by slug: the_slug
    counter = 1
    while obj && obj != self
      the_slug = append_suffix(the_slug, counter)
      obj = self.class.find_by slug: the_slug
      counter += 1
    end
    self.slug = the_slug
  end

  def to_slug(name)
    str = name.strip.downcase
    str.gsub! /\s*[^a-z0-9]\s*/, '-'
    str.gsub /-+/, '-'
  end

  def append_suffix(str, counter)
    if str.split('-').last.to_i != 0
      the_slug = str.split('-').slice(0...-1).join('-') << '-' << counter.to_s
    else
      the_slug = str << '-' << counter.to_s
    end
  end
  
  module ClassMethods
    def sluggable_column(column_name)
      self.slug_column = column_name
    end        
  end
  
end