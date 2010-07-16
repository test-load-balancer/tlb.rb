require File.join(File.dirname(__FILE__), 'spec_helper.rb')
require 'tlb_spec_formatter'
require 'spec/example/example_proxy'
require 'spec/example/example_group_proxy'

describe Tlb::TlbSpecFormatter do
  before :all do
    FileUtils.mkdir_p(@dir = "./tmp/formatter_test")
  end

  before do
    @group_1, @file_1 = stubbed_group("group1")
    @group_2, @file_2 = stubbed_group("group2")
    @group_3, @file_3 = stubbed_group("group3")
    @group_proxy_1 = Spec::Example::ExampleGroupProxy.new(@group_1)
    @group_proxy_2 = Spec::Example::ExampleGroupProxy.new(@group_2)
    @group_proxy_3 = Spec::Example::ExampleGroupProxy.new(@group_3)
    @formatter = Tlb::TlbSpecFormatter.new(nil, nil)
  end

  def stubbed_group group_name
    grp = stub(group_name)
    grp.expects(:description).returns("#{group_name} desc")
    grp.expects(:nested_descriptions).returns("#{group_name} nested desc")
    grp.expects(:example_proxies).returns("#{group_name} example proxies")
    grp.expects(:options).returns({:name => group_name})

    File.open(file = "#{@dir}/#{group_name}.rb", 'w') do |h|
      h.write("something")
    end
    file = File.expand_path(file)
    grp.expects(:location).times(2).returns(file + ":4")

    [grp, file]
  end

  it "should be silent formatter" do
    @formatter.should be_a(Spec::Runner::Formatter::SilentFormatter)
  end

  it "should use last heard example_passed/example_failed/example_pending" do
    Time.expects(:now).returns(Time.local( 2010, "jul", 16, 12, 5, 10))
    @formatter.example_group_started(@group_proxy_1)
    Time.expects(:now).returns(Time.local( 2010, "jul", 16, 12, 5, 20))
    @formatter.example_passed(Spec::Example::ExampleProxy.new("group1 spec 1", {}, "#{@dir}/group1.rb:12"))
    Time.expects(:now).returns(Time.local( 2010, "jul", 16, 12, 5, 22))
    @formatter.example_failed(Spec::Example::ExampleProxy.new("group1 spec 2", {}, "#{@dir}/group1.rb:40"), 1, "ignore")
    Time.expects(:now).returns(Time.local( 2010, "jul", 16, 12, 5, 29))
    @formatter.example_pending(Spec::Example::ExampleProxy.new("group1 spec 3", {}, "#{@dir}/group1.rb:55"), "some reason")

    Time.expects(:now).returns(Time.local( 2010, "jul", 16, 12, 6, 00))
    @formatter.example_group_started(@group_proxy_2)
    Time.expects(:now).returns(Time.local( 2010, "jul", 16, 12, 6, 12))
    @formatter.example_pending(Spec::Example::ExampleProxy.new("group2 spec 1", {}, "#{@dir}/group2.rb:5"), "some reason")
    Time.expects(:now).returns(Time.local( 2010, "jul", 16, 12, 6, 25))
    @formatter.example_passed(Spec::Example::ExampleProxy.new("group2 spec 2", {}, "#{@dir}/group2.rb:38"))

    Time.expects(:now).returns(Time.local( 2010, "jul", 16, 12, 7, 15))
    @formatter.example_group_started(@group_proxy_3)
    Time.expects(:now).returns(Time.local( 2010, "jul", 16, 12, 8, 12))
    @formatter.example_pending(Spec::Example::ExampleProxy.new("group3 spec 1", {}, "#{@dir}/group3.rb:45"), "some reason")
    Time.expects(:now).returns(Time.local( 2010, "jul", 16, 12, 8, 55))
    @formatter.example_failed(Spec::Example::ExampleProxy.new("group3 spec 2", {}, "#{@dir}/group3.rb:80"), 3, "ignore")

    Tlb.stubs(:suite_result)

    Tlb.expects(:suite_time).with(@file_1, 19000)
    Tlb.expects(:suite_time).with(@file_2, 25000)
    Tlb.expects(:suite_time).with(@file_3, 100000)

    @formatter.start_dump
  end
end