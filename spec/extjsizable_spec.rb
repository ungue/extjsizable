require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "Extjsizable" do

  describe Category do

    describe "valid" do
      before do
        @category = Category.new :name => 'The category'
      end

      it "should return success : true  and a data section" do 
        @category.should be_valid

        json_hash = parse_json(@category.to_ext_json).with_indifferent_access

        json_hash.should_not be_empty
        json_hash.should have_key(:success)
        json_hash[:success].should be_true

        json_hash.should have_key(:data)
      end

      it "should return all attributes prefixed with the class name" do
        json_hash = parse_json(@category.to_ext_json).with_indifferent_access
        json_hash[:data].should have_key('category[name]')
      end  
      
      it "should return all atributes and the result of the methods specified when called with :methods => [...]" do
        json_hash = parse_json(@category.to_ext_json(:methods => [:my_method])).with_indifferent_access
        json_hash[:data].should have_key('category[name]')
        json_hash[:data].should have_key('category[my_method]')
      end

      it "should return success : false and an empty errors section when called with :success => false" do
        json_hash = parse_json(@category.to_ext_json(:success => false)).with_indifferent_access
        
        json_hash.should have_key(:success)
        json_hash[:success].should be_false

        json_hash.should_not have_key(:data)

        json_hash.should have_key(:errors)
        json_hash[:errors].should be_empty
      end
    end

    describe "not valid" do
      before do
        @category = Category.new
      end

      it "should return success : false and an errors section" do 
        @category.should_not be_valid

        json_hash = parse_json(@category.to_ext_json).with_indifferent_access

        json_hash.should_not be_empty
        json_hash.should have_key(:success)
        json_hash[:success].should be_false

        json_hash.should have_key(:errors)
      end
      
      it "should return all failed attributes prefixed with the class name" do
        json_hash = parse_json(@category.to_ext_json).with_indifferent_access
        json_hash[:errors].should have_key('category[name]')
      end  
    end
  end


end
