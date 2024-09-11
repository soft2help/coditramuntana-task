# Generate badge of simple cov on root of project
# on spec/spec_helper.rb
# require "badge_formatter" on top of file
# and add inside block SimpleCov.start "rails" do
#   SimpleCov.formatter =
# SimpleCov::Formatter::MultiFormatter.new \
# [SimpleCov::Formatter::HTMLFormatter, BadgeFormatter]
class BadgeFormatter < SimpleCov::Formatter::BadgeFormatter
  def result_file_path
    File.join(Rails.root.to_s, RESULT_FILE_NAME)
  end
end
