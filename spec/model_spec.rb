require 'spec_helper'

describe "Cistern::Model" do

  context "attribute parsing" do
    class TypeSpec < Cistern::Model
      identity :id
      attribute :name, type: :string
      attribute :created_at, type: :time
      attribute :flag, type: :boolean
      attribute :custom, parser: lambda{|v, opts| "X!#{v}"}
    end

    it "should parse string" do
      TypeSpec.new(name: 1).name.should == "1"
    end

    it "should parse time" do
      time = Time.now
      created_at = TypeSpec.new(created_at: time.to_s).created_at
      created_at.should be_a(Time)
      created_at.to_i.should == time.to_i
    end

    it "should parse boolean" do
      TypeSpec.new(flag: "false").flag.should be_false
      TypeSpec.new(flag: "true").flag.should be_true
      TypeSpec.new(flag: false).flag.should be_false
      TypeSpec.new(flag: true).flag.should be_true
    end

    it "should use custom parser" do
      TypeSpec.new(custom: "15").custom.should == "X!15"
    end
  end

  context "inspection engine" do
    class InspectorSpec < Cistern::Model
      identity :id
      attribute :name
    end

    after(:all) do
      InspectorSpec.formatter= Cistern::Formatter::Default
    end

    it "should default to default formatter" do
      InspectorSpec.formatter.should == Cistern::Formatter::Default
    end

    it "should use default" do
      InspectorSpec.new(id: 1, name: "name").inspect.should match /#<InspectorSpec:0x[0-9a-f]+ attributes={id:1,name:\"name\"}/
    end

    it "should use awesome_print" do
      defined?(AwesomePrint).should be_false # don't require if not used
      InspectorSpec.formatter= Cistern::Formatter::AwesomePrint

      InspectorSpec.new(id: 1, name: "name").inspect.match /(?x-mi:\#<InspectorSpec:0x[0-9a-f]+>\ {\n\ \ \ \ \ \ :id\x1B\[0;37m\ =>\ \x1B\[0m\x1B\[1;34m1\x1B\[0m,\n\ \ \ \ :name\x1B\[0;37m\ =>\ \x1B\[0m\x1B\[0;33m"name"\x1B\[0m\n})/
    end

    it "should use formatador" do
      defined?(Formatador).should be_false # don't require if not used
      InspectorSpec.formatter= Cistern::Formatter::Formatador

      InspectorSpec.new(id: 1, name: "name").inspect.should == "  <InspectorSpec\n    id=1,\n    name=\"name\"\n  >"
    end
  end
end