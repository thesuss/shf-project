#  Matcher for FileSetBackupMakers

RSpec::Matchers.define :eq_the_fileset_backup_maker do |expected|
  match do |actual|
    expected.name == actual.name &&
        expected.days_to_keep == actual.days_to_keep &&
        expected.base_filename == actual.base_filename &&
        expected.excludes == actual.excludes &&
        expected.target_filename == actual.target_filename &&
        expected.backup_sources == actual.backup_sources
  end

  failure_message do |actual|
    "      expected: #{expected.inspect}\nbut got actual: #{actual.inspect}"
  end
end
