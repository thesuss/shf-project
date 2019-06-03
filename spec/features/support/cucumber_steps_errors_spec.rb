require 'rails_helper'

require_relative File.join(Rails.root, 'features', 'support', 'step_errors')


# --------------------------------------------

RSpec.shared_examples 'it shows the previous error when this one is raised (nested errors)' do | raised_shf_error |

  it 'previous error message is displayed so the context is clear' do
    begin
      # Artificially create a previous error that has happened
      raise NoMethodError

    rescue NoMethodError
      # Create (raise) one of our errors (some SHFStepsError)
      begin
        raise raised_shf_error
      rescue raised_shf_error.class => shf_error
        # This is the rescue statement that will catch our error
        # This is the rescue statement that will happen in real code.
      end
    end

    expect(shf_error.message).to match(/This was raised after this error: NoMethodError\./)
  end
end

# --------------------------------------------

RSpec.describe 'Cucumber Steps Errors' do

  describe 'SHFStepsError' do

    let(:error_class) { SHFStepsError }

    it_behaves_like 'it shows the previous error when this one is raised (nested errors)', SHFStepsError.new

    it 'shows just the class name if no previous error was raised' do
      begin
        # Create (raise) one of our errors (some SHFStepsError)
        raise error_class

      rescue NoMethodError, error_class
        # This is the rescue statement that will catch one of our errors (SHFStepsError).
        # This is the rescue statement that will happen in real code.
        shf_error = error_class.new
      end

      expect(shf_error.message).to eq "SHFStepsError"
    end

  end


  describe 'PagenameUnknown' do

    it 'default message is PagenameUnknown with a reminder to add it to the known pages ' do
      expect(PagenameUnknown.new.message).to eq "PagenameUnknown: The page name is unknown.\n  You may need to add it to the list of known paths in the get_path() case statement."
    end

    it 'message includes the specific page name if one is given' do
      expect(PagenameUnknown.new(page_name: 'blorfo').message).to eq "PagenameUnknown: The page name 'blorfo' is unknown.\n  You may need to add it to the list of known paths in the get_path() case statement."
    end

    it_behaves_like 'it shows the previous error when this one is raised (nested errors)', PagenameUnknown.new(page_name: 'blorfo')

  end


  describe 'UnableToVisitConstructedPath' do

    it 'default message is UnableToVisitConstructedPath with a reminder to maybe add it to the list of known pages/paths' do
      expect(UnableToVisitConstructedPath.new.message).to eq "UnableToVisitConstructedPath: Unable to visit the manually constructed path.\n  You may need to add it to the list of known paths in the get_path() case statement."
    end

    it 'message includes the specific constructed path if one is given' do
      expect(UnableToVisitConstructedPath.new(constructed_path: 'something_blorfo_page').message).to eq "UnableToVisitConstructedPath: Unable to visit the manually constructed path 'something_blorfo_page'.\n  You may need to add it to the list of known paths in the get_path() case statement."
    end

    it_behaves_like 'it shows the previous error when this one is raised (nested errors)', UnableToVisitConstructedPath.new(constructed_path: 'some_constructed_path')

  end

end
