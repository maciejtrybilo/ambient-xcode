def option(name, value)
  Ambient.configure { set_option(name, value) }
end

def enable_warnings_and_static_analyser!
  warnings = %w(GCC_WARN_INITIALIZER_NOT_FULLY_BRACKETED
    GCC_WARN_MISSING_PARENTHESES
    GCC_WARN_ABOUT_RETURN_TYPE
    GCC_WARN_SIGN_COMPARE
    GCC_WARN_CHECK_SWITCH_STATEMENTS
    GCC_WARN_UNUSED_FUNCTION
    GCC_WARN_UNUSED_LABEL
    GCC_WARN_UNUSED_VALUE
    GCC_WARN_UNUSED_VARIABLE
    GCC_WARN_SHADOW
    GCC_WARN_64_TO_32_BIT_CONVERSION
    GCC_WARN_ABOUT_MISSING_FIELD_INITIALIZERS
    GCC_WARN_UNDECLARED_SELECTOR
    GCC_WARN_TYPECHECK_CALLS_TO_PRINTF
    GCC_WARN_UNINITIALIZED_AUTOS
    CLANG_WARN_INT_CONVERSION
    CLANG_WARN_ENUM_CONVERSION
    CLANG_WARN_CONSTANT_CONVERSION
    CLANG_WARN_BOOL_CONVERSION
    CLANG_WARN_EMPTY_BODY
    CLANG_WARN_SUSPICIOUS_IMPLICIT_CONVERSION
    CLANG_WARN__DUPLICATE_METHOD_MATCH
    GCC_WARN_64_TO_32_BIT_CONVERSION
    RUN_CLANG_STATIC_ANALYZER
    GCC_TREAT_WARNINGS_AS_ERRORS)
  warnings.each { |w| option(w, true) }
end

def target(name, &block)
  TargetScope.new(name).configure(&block)
end

def use_defaults_for_everything_not_specified_in_this_file!
  Ambient.configure { @use_defaults = true }
end

class TargetScope
  attr_reader :name

  def initialize(name)
    @name = name
  end

  def configure(&block)
    instance_eval(&block)
  end

  def option(option_name, value)
    target_name = @name
    Ambient.configure { set_option(option_name, value, target: target_name) }
  end

  def scheme(name, parent: nil, &block)
    SchemeScope.new(self, name, parent).configure(&block)
  end
end

class SchemeScope
  def initialize(target, name, parent)
    @target = target
    @name = name
    @parent = parent

    child = name
    Ambient.configure { set_parent_target(target.name, child, parent) }
  end

  def configure(&block)
    instance_eval(&block)
  end

  def option(option_name, value)
    target = @target
    name = @name
    parent = @parent

    Ambient.configure do
      # require 'pry'; binding.pry
      set_option(option_name, value, target: target.name, scheme: name, parent: parent)
    end
  end
end