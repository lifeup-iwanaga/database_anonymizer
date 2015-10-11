Rails.application.routes.draw do

  mount DatabaseAnonymizer::Engine => "/database_anonymizer"
end
