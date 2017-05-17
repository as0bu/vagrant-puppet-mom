require 'facter'
Facter.add(:vagrant_git_env) do
  setcode do
    if File.exists?('/vagrant/.git')
      Facter::Util::Resolution.exec("git --git-dir /vagrant/.git rev-parse --abbrev-ref HEAD")
    else
      'false'
    end
  end
end
