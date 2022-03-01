module HmctsCommonPlatform
  class ContactDetails
    attr_reader :data

    delegate :blank?, to: :data

    def initialize(data)
      @data = HashWithIndifferentAccess.new(data || {})
    end

    def phone_home
      data[:home]
    end

    def phone_work
      data[:work]
    end

    def phone_mobile
      data[:mobile]
    end

    def email_primary
      data[:primaryEmail]
    end

    def email_secondary
      data[:secondaryEmail]
    end

    def fax
      data[:fax]
    end

    def to_json(*_args)
      return {} if attrs.all? { |_k, v| v.blank? }

      attrs
    end

  private

    def attrs
      @attrs ||= to_builder.attributes!
    end

    def to_builder
      Jbuilder.new do |contact_details|
        contact_details.home phone_home
        contact_details.work phone_work
        contact_details.mobile phone_mobile
        contact_details.email_primary email_primary
        contact_details.email_secondary email_secondary
        contact_details.fax fax
      end
    end
  end
end
