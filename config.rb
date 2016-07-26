configure :build do
end

activate :deploy do |deploy|
  deploy.deploy_method = :git
  deploy.branch   = "build" # default: gh-pages
end
