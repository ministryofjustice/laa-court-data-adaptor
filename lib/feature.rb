class Feature
  def self.enabled?(feature_name)
    case feature_name
    when "multiday_hearings"
      FeatureFlag.exists?(name: feature_name, enabled: true)
    else
      false
    end
  end
end
