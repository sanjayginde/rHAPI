require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "RHapi::Blog" do
  
  context "connection" do
    before do
      RHapi.configure do |config|
        config.api_key = test_config["api_key"]
        config.hub_spot_site = "http://mysite.hubspot.com"
      end
      @url = "https://hubapi.com/blogs/v1/list?hapikey=#{test_config["api_key"]}"
    end
    it "should generate a url with a search param" do
      url = RHapi::Blog.url_for("list", nil, {:search => "test"})
      url.should == @url << "&search=test"
    end
    it "should generate a url with multiple params" do
      url = RHapi::Blog.url_for("list", nil, {:search => "test", :sort => "firstName", :dir => "asc", :max => 10})
      url.include?("&sort=firstName").should == true
      url.include?("&search=test").should == true
      url.include?("&dir=asc").should == true
      url.include?("&max=10").should == true
    end
    it "should generate a url with an id" do
      url = RHapi::Blog.url_for("Blog", "myid")
      url.should == "https://hubapi.com/Blogs/v1/Blog/myid?hapikey=#{test_config["api_key"]}"
    end
    it "should raise a url error if options is not a hash" do
      lambda {RHapi::Blog.url_for("list", nil, nil)}.should raise_error(RHapi::UriError)
    end
  end
  
  context "when searching for Blogs" do
    before do
      RHapi.configure do |config|
        config.api_key = test_config["api_key"]
        config.hub_spot_site = "http://mysite.hubspot.com"
      end
      # stub_blogs_search
    end
    
    # Most of the actual connections are mocked to spped tests.
    it "should return all Blogs with no search params" do
      Blogs = RHapi::Blog.find
      Blogs.length.should >= 1
    end
    
    it "should have a blogTitle attribute" do
      Blogs = RHapi::Blog.find
      Blogs.first.blogTitle.should_not be_nil
    end
    
    it "should have a guid attribute" do
      Blogs = RHapi::Blog.find
      Blogs.first.guid.should_not be_nil
    end
  
  end
  
  context "creating a post" do
    
    before do
      RHapi.configure do |config|
        config.api_key = test_config["api_key"]
        config.hub_spot_site = "http://mysite.hubspot.com"
      end
      # stub_blogs_search
    end
    
    it "should post" do
      blogs = RHapi::Blog.find
      puts blogs[0].create("testapi@hubspot.com", "Test User", "Test Blog Post", "Test content would go here.")
    end
  
  end

  context "get Blog information with guid" do
    before do
      RHapi.configure do |config|
        config.api_key = test_config["api_key"]
        config.hub_spot_site = "http://mysite.hubspot.com"
      end
      stub_blogs_search
    end
    
    it "should return a Blog" do
      Blogs = RHapi::Blog.find
      stub_blogs_find_by_guid
      Blog = RHapi::Blog.find_by_guid(Blogs.first.guid)
      Blog.first_name.should == "Fred"
    end
    
    it "should raise an error if an error string is returned" do
      stub_blogs_error
      lambda {RHapi::Blog.find_by_guid("badguid")}.should raise_error(RHapi::ConnectionError)
    end
  end
  
  
  context "accessing Blogs with incorrect API key" do
    before do
     RHapi.configure do |config|
        config.api_key = "badapikey"
        config.hub_spot_site = "http://mysite.hubspot.com"
      end
    end
    
    it "should raise an exception" do
      stub_blogs_error
      lambda {RHapi::Blog.find}.should raise_error(RHapi::ConnectionError)
    end
  end
  
  
end

