require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "Extjsizable" do

  describe Category do

    describe "valid" do
      before do
        @category = Category.new :name => 'The category'
      end

      it "should return success : true and a data section when not ActiveRecord::Base.include_root_in_json" do 
        ActiveRecord::Base.include_root_in_json = false
        @category.should be_valid

        json_hash = @category.to_extjs

        json_hash.should_not be_empty
        json_hash.should have_key(:success)
        json_hash[:success].should be_true

        json_hash.should have_key(:data)
      end
      
      it "should return success : true and a category section when ActiveRecord::Base.include_root_in_json" do 
        ActiveRecord::Base.include_root_in_json = true
        @category.should be_valid

        json_hash = @category.to_extjs

        json_hash.should_not be_empty
        json_hash.should have_key(:success)
        json_hash[:success].should be_true
        json_hash.should have_key(:category)
      end

      it "should return the attribute name of category" do
        json_hash = @category.to_extjs
        json_hash[:category].should have_key(:name)
      end  
       
      it "should return all atributes and the result of the methods specified when called with :methods => [...]" do
        json_hash = @category.to_extjs(:methods => :my_method)
        json_hash[:category].should have_key(:name)
        json_hash[:category].should have_key(:my_method)
      end

      it "should return success : false and an empty errors section when called with :success => false" do
        json_hash = @category.to_extjs(:success => false)
        
        json_hash.should have_key(:success)
        json_hash[:success].should be_false

        json_hash.should_not have_key(:data)
        json_hash.should_not have_key(:category)

        json_hash.should have_key(:errors)
        json_hash[:errors].should be_empty
      end
    end

    describe "not valid" do
      before do
        Category.delete_all
        @category = Category.new
        @category.save
      end

      it "should return success : false and an errors section" do 
        @category.should_not be_valid

        json_hash = @category.to_extjs

        json_hash.should_not be_empty
        json_hash.should have_key(:success)
        json_hash[:success].should be_false

        json_hash.should have_key(:errors)
      end
      
      it "should return the failed attribute name" do
        json_hash = @category.to_extjs
        json_hash[:errors].should have_key(:name)
      end  
    end
  end

  describe Array do
    before(:all) { ActiveRecord::Base.include_root_in_json = false }

    describe 'empty' do
      before do
        @array = []
      end

      it 'should return { total => 0, data => [] }' do
        json_hash = @array.to_extjs
        json_hash.should have_key(:total)
        json_hash[:total].should == 0
        json_hash.should have_key(:data)
        json_hash[:data].should be_empty
      end
    end
    
    describe 'with 4 categories with some products each' do
      before do
        Product.delete_all
        Category.delete_all

        4.times do |i|
          c = Category.new :name => "Category #{i}"
          c.products = Array.new(2) { |j| Product.new :name => "Product #{j}" }
          c.save
        end

        @array = Category.all
      end

      it 'should return { :total => 4, :data => [{ "id" => ..., "name" => "Category ..."}, ...] }' do
        json_hash = @array.to_extjs
        json_hash.should have_key(:total)
        json_hash[:total].should == 4

        json_hash.should have_key(:data)
        json_hash[:data].should have(4).categories
        json_hash[:data].each do |h| 
          h.should have_key('id')
          h.should have_key('name')
        end
      end

      it 'should return only id attributes when called with :only => :id ' do
        json_hash = @array.to_extjs :only => :id
        json_hash.should have_key(:total)
        json_hash[:total].should == 4

        json_hash.should have_key(:data)
        json_hash[:data].should have(4).categories
        json_hash[:data].each do |h| 
          h.should have_key('id')
          h.should_not have_key('name')
        end
      end
      
      it 'should return only name attributes when called with :except => :id ' do
        json_hash = @array.to_extjs :except => :id
        json_hash.should have_key(:total)
        json_hash[:total].should == 4

        json_hash.should have_key(:data)
        json_hash[:data].should have(4).categories
        json_hash[:data].each do |h| 
          h.should have_key('name')
          h.should_not have_key('id')
        end
      end
      
      it 'should return only related data attributes with :include => :products ' do
        json_hash = @array.to_extjs :include => :products
        json_hash.should have_key(:total)
        json_hash[:total].should == 4

        json_hash.should have_key(:data)
        json_hash[:data].should have(4).categories
        json_hash[:data].each do |h| 
          h.should have_key('name')
          h.should have_key('id')
          h.should have_key('products')
          h[:products].should have(2).items
        end
      end

    end
  end


end
