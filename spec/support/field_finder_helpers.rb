module FieldFinderHelpers
  def find_field_by_name(field_name)
    Field.new(field_name, page).find_by_field_name
  end

  def find_field_by_data_role(data_role)
    Field.new(data_role, page).find_by_data_role
  end

  private

  class Field
    def initialize(field_name_or_data_role, page)
      @field_name_or_data_role = field_name_or_data_role
      @page = page
    end

    def find_by_field_name
      with_error_message(%{Cannot find field with name "#{@field_name_or_data_role}"}) do
        @page.find_field(@field_name_or_data_role)
      end
    end

    def find_by_data_role
      with_error_message(%{Cannot find field with data-role "#{@field_name_or_data_role}"}) do
        @page.find("input[data-role='#{@field_name_or_data_role}']")
      end
    end

    private

    def with_error_message(message)
      begin
        yield
      rescue Capybara::ElementNotFound => e
        raise e.class, message
      end
    end
  end
end

RSpec.configure do |c|
  c.include FieldFinderHelpers
end
