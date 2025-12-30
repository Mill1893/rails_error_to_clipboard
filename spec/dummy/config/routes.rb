# frozen_string_literal: true

Rails.application.routes.draw do
  get "/test", to: "pages#test"
  get "/error", to: "pages#error"
end
