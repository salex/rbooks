# frozen_string_literal: true

module GoldMenu
  class Component < ViewComponent::Base
    def initialize(title:, links:, action:"get")
      @title = title
      @links = links
      @action = action
    end

  end
end