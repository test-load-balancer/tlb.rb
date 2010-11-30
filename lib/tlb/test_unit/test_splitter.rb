module Tlb::TestSplitter
  def prune_suite
    name_suite_map = @suite.tests.inject({}) { |map, test| map[test.name] = test; map }
    names_to_run = Tlb.balance_and_order(@suite.tests.map { |test| test.name })
    tests_to_run = names_to_run.inject([]) { |tests, name| tests << name_suite_map[name]; tests }
    @suite.instance_variable_set('@tests', tests_to_run)
  end
end