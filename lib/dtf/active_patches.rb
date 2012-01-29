unless String.method_defined? :blank?
  String.class_eval do
    def blank?
      self == ""
    end
  end
end
unless NilClass.method_defined? :blank?
  NilClass.class_eval do
    def blank?
      true
    end
  end
end
