module HmctsCommonPlatform
  class Person
    attr_reader :data

    delegate :blank?, to: :data

    def initialize(data)
      @data = HashWithIndifferentAccess.new(data || {})
    end

    def title
      data[:title]
    end

    def gender
      data[:gender]
    end

    def first_name
      data[:firstName]
    end

    def middle_name
      data[:middleName]
    end

    def last_name
      data[:lastName]
    end

    def full_name
      [first_name, middle_name, last_name].join(" ").squish
    end

    def date_of_birth
      data[:dateOfBirth]
    end

    def nino
      data[:nationalInsuranceNumber]
    end

    def occupation
      data[:occupation]
    end

    def occupation_code
      data[:occupationCode]
    end

    def documentation_language_needs
      data[:documentationLanguageNeeds]
    end

    def address
      HmctsCommonPlatform::Address.new(data[:address])
    end

    def contact_details
      HmctsCommonPlatform::ContactDetails.new(data[:contact])
    end

    def to_json(*_args)
      return {} if attrs.all? { |_k, v| v.blank? }

      attrs
    end

  private

    def to_builder
      Jbuilder.new do |person|
        person.title title
        person.gender gender
        person.name full_name
        person.first_name first_name
        person.middle_name middle_name
        person.last_name last_name
        person.full_name full_name
        person.date_of_birth date_of_birth
        person.nino nino
        person.occupation occupation
        person.occupation_code occupation_code
        person.documentation_language_needs documentation_language_needs
      end
    end

    def attrs
      @attrs ||= to_builder.attributes!
    end
  end
end
