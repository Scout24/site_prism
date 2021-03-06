require 'site_prism/loadable'

module SitePrism
  class Section
    include Capybara::DSL
    include ElementChecker
    include Loadable
    include LambdaResolver
    extend ElementContainer

    attr_reader :root_element, :parent

    def initialize(parent, root_element)
      @parent = parent
      @root_element = root_element
      Capybara.within(@root_element) { yield(self) } if block_given?
    end

    def visible?
      root_element.visible?
    end

    def text
      root_element.text
    end

    def execute_script(input)
      Capybara.current_session.execute_script input
    end

    def evaluate_script(input)
      Capybara.current_session.evaluate_script input
    end

    def parent_page
      candidate_page = parent
      until candidate_page.is_a?(SitePrism::Page)
        candidate_page = candidate_page.parent
      end
      candidate_page
    end

    private

    def find_first(*find_args)
      root_element.find(*resolve_lambdas(find_args))
    end

    def find_all(*find_args)
      root_element.all(*resolve_lambdas(find_args))
    end

    def element_exists?(*find_args)
      root_element.has_selector?(*resolve_lambdas(find_args)) unless root_element.nil?
    end

    def element_does_not_exist?(*find_args)
      root_element.has_no_selector?(*resolve_lambdas(find_args)) unless root_element.nil?
    end
  end
end
