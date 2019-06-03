#
# @module VisitPage
#
# @description Method for visiting a page (including exception handling).
#
# This is a module so that it can be easily tested.
#
module VisitPage

  def visit_page(page, user)


    visit path_with_locale(get_path(page, user))

  rescue PagenameUnknown

    begin

      constructed_path = create_manually_underscored_path(page)

      # try to manually construct the path if we couldn't match it to ones we know
      visit self.send(constructed_path.to_sym)

    rescue ArgumentError, NoMethodError => no_method_or_args_error
      constructed_path_error = UnableToVisitConstructedPath.new(constructed_path: constructed_path)
      raise constructed_path_error, "#{constructed_path_error}:: Original Error: #{no_method_or_args_error}"


    rescue => some_other_error
      raise some_other_error

    end

  rescue => not_a_path_error
    raise not_a_path_error

  end

end
