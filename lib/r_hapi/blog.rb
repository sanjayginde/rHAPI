require 'rubygems'
require 'active_support'
require 'active_support/inflector/inflections'
require File.expand_path('../connection', __FILE__)

module RHapi

  class Blog
    include Connection
    extend Connection::ClassMethods

    attr_accessor :attributes, :changed_attributes

    def initialize(data)
      self.attributes = data
      self.changed_attributes = {}
    end

    # Class methods ----------------------------------------------------------
    def self.test_run
      #puts url_for("blog", "blablahabalah",{:version=>"v1"} , "blog")
      #response = post(url_for("blog", "blablahabalah",{:version=>"v1"} , "blog"), "")
    end

    def self.find(search=nil, options={})
      options[:search] = search unless search.nil?
      response = get(url_for(
        :api => 'blog',
        :resource => 'list'))

      blogs_data = JSON.parse(response.body_str)
      blogs = []
      blogs_data.each do |data|
        blog = Blog.new(data)
        blogs << blog
      end
      blogs
    end

    # Finds specified lead by the guid.
    def self.find_by_guid(guid)
      response = get(url_for("blog", guid, "blog"))
      lead_data = JSON.parse(response.body_str)
      Blog.new(lead_data)
    end


    #Instance Methods --


    def create(writer_email, author, title, content)
       response = post(Blog.url_for("", self.guid, {:posts=>"posts.atom"} , "blog"), get_xml({:email=>writer_email, :content => content, :title=> title, :author => author }))
       response_hash = Hash.from_xml(response.body_str)
       return response_hash["feed"]["entry"]["link"]["href"] #return url
    end



    def get_xml(hash_in)
     resp = <<-eos
<?xml version="1.0" encoding="utf-8"?>
<entry xmlns="http://www.w3.org/2005/Atom">
  <title> #{hash_in[:title]}</title>
     <author>
       <name>#{hash_in[:author]}</name>
       <email>#{hash_in[:email]}</email>
     </author>
     <summary>#{hash_in[:summary] if hash_in[:summary]}</summary>
     <content type="html"><![CDATA[#{hash_in[:content]}]]></content>
</entry>
      eos


      resp


    end

    # Work with data in the data hash
    def method_missing(method, *args, &block)

      attribute = ActiveSupport::Inflector.camelize(method.to_s, false)

      if attribute =~ /=$/
        attribute = attribute.chop
        return super unless self.attributes.include?(attribute)
        self.changed_attributes[attribute] = args[0]
        self.attributes[attribute] = args[0]
      else
        return super unless self.attributes.include?(attribute)
        self.attributes[attribute]
      end

    end

  end

end
