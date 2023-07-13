require_relative 'lib/webhook.rb'

require 'inferno'
use Rack::Static,
    urls: Inferno::Utils::StaticAssets.static_assets_map,
    root: Inferno::Utils::StaticAssets.inferno_path

Inferno::Application.finalize!

use Inferno::Utils::Middleware::RequestLogger

run Rack::Cascade.new([Sinatra::Application, Inferno::Web.app])
