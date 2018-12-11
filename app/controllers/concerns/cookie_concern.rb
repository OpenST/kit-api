module CookieConcern

  extend ActiveSupport::Concern

  included do
    # add all before / after filters / callbacks here
  end

  class_methods do
    # add all class methods here
  end

  # instance methods
  def cookie_key(name)
    "ost_kit_#{name}"
  end

end
