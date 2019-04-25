module ValidatorHelper
  def test_model_class
    Class.new do
      include ActiveModel::Validations

      attr_accessor :test_attr
    end
  end
end
