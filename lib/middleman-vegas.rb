require 'middleman-core'
require 'middleman-vegas/version'
require 'middleman-vegas/extension'

::Middleman::Extensions.register(:vegas, ::Middleman::Vegas::SyntaxExtension)
