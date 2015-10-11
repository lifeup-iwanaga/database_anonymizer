module DatabaseAnonymizer
  class Engine < ::Rails::Engine
    isolate_namespace DatabaseAnonymizer
  end
end
