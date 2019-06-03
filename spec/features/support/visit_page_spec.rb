require 'rails_helper'

require_relative File.join(Rails.root, 'features', 'support', 'step_errors')
require_relative File.join(Rails.root, 'features', 'support', 'path_helpers')
require_relative File.join(Rails.root, 'features', 'support', 'visit_page')

class VisitPageTester
  include PathHelpers
  include VisitPage

  # fake path method
  def faux_path
    true
  end


  # stub the 'visit' method
  def visit(_visit_path)
    true
  end


  # stub  root_path
  def root_path
    true
  end


  # stub path_with_locale
  def path_with_locale(path)
    path
  end
end


RSpec.describe VisitPage do

  let(:subject) { VisitPageTester.new }


  describe 'visit_page error handling' do

    context 'page_name is not in list of known pages' do

      it 'then tries to visit the manually constructed page path' do
        expect(subject).to receive(:create_manually_underscored_path).and_call_original

        # faux_path  is a valid method
        subject.visit_page('faux', 'flurb')
      end


      context 'error when trying to visit the page path' do

        it 'raises UnableToVisitPath and shows the preceding error message so that is not lost/swallowed' do
          expect { subject.visit_page('blorf', 'flurb') }.to raise_exception do | actual_exception |
            expect(actual_exception).to be_a UnableToVisitConstructedPath
            expect(actual_exception.message).to match( /UnableToVisitConstructedPath: This was raised after this error: undefined method `blorf_path' for (.*).: Unable to visit the manually constructed path 'blorf_path'.\n(\s+)You may need to add it to the list of known paths in the get_path\(\) case statement./)
          end
        end

        it 'raises any other error' do
          expect { subject.send(:visit_page, 'faux') }.to raise_exception(ArgumentError)
        end
      end


      #it 'no errors: successfully visited the page' do
      # This is not tested.  To do so we'll need to stub _all methods_ in the case statement.
      # Not helpful at this time. We're currently interested only in verifying that error handling
      # is correct.
      #end
    end


    context 'page_name is in the list of known pages' do

      it 'some error is raised (not SHFError)' do
        allow(subject).to receive(:path_with_locale).and_raise(NoMethodError)
        expect { subject.visit_page('landing', 'flurb') }.to raise_error(NoMethodError)
      end
    end

  end
end
