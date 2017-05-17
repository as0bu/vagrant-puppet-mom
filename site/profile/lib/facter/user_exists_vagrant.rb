require 'facter'
Facter.add(:user_exists_vagrant) do
  setcode do
    user_id = Facter::Util::Resolution.exec("/usr/bin/id -u vagrant 2>/dev/null")
    if user_id.nil?
      'false'
    else
      'true'
    end
  end
end
