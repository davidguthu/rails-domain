require 'ostruct'
require_relative '../../../spec_helper.rb'

describe RailsDomain::BaseDomain do
  subject { RailsDomain::BaseDomain }
  let(:args) { Hash.new }
  let(:persistence_class) { OpenStruct.new }
  let(:associations) { [] }

  before do
    subject.stub(:persistence_class => persistence_class)
    persistence_class.stub(:reflect_on_all_associations => associations)
  end

  describe "#initialize" do

    describe "with hash arguments" do
      it "should create a new persistence object with args" do
        persistence_class.should_receive(:new).with(args)
        subject.new(args)
      end
    end

    describe "with nil arguments" do
      let(:args) { nil }
      it "should create a new persistence object" do
        persistence_class.should_receive(:new)
        subject.new(args)
      end
    end

    describe "with object argument" do
      let(:args) { OpenStruct.new(:id => 1) }

      it "should set the @persistence_object instance var" do
        domain_object = subject.new(args)
        domain_object.persistence_object.should == args
      end
    end

  end

  describe "#wrap objects" do
    pending
  end

end

